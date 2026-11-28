# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private"].freeze
  DISTRACTOR_POOLS = ["category", "preset", "none"].freeze
  GOAL_MODES = ["none", "session", "target"].freeze
  NAME_SOURCE = Arel.sql("COALESCE(decks.name, word_lists.name)")
  # A word climbs a level with each day it is answered right and is
  # finished at this streak. Music decks go by rounds instead.
  LEVELS = 3
  # Mirrors StudyDay#study_goal.
  GOAL_UNMET = <<~SQL.squish
    study_days.completed_count <
      CASE WHEN decks.goal_mode = 'target' AND study_days.goal IS NOT NULL
        THEN study_days.goal
        ELSE decks.study_goal
      END
  SQL
  GUEST_CARD_LIMIT = 100
  # Whether a language card had a sense answered correctly today (true) or
  # none did (false), keyed by `practice` in `LanguageDeck#study_pool`.
  SENSES_CORRECT_TODAY = {
    true => "MAX(skill_scores.last_correct_at) >= ?",
    false => "COALESCE(MAX(skill_scores.last_correct_at) < ?, TRUE)",
  }.freeze
  Progress = Data.define(:total, :done, :level1, :level2, :level3)
  # The steps rows have left to finish: a word at level 2 has two.
  STEPS_LEFT = Arel.sql("SUM(GREATEST(#{LEVELS} - rows.correct_streak, 0))")
  # Mirrors #finish_streak.
  FINISH_STREAK =
    "CASE WHEN decks.type = 'MusicDeck' THEN decks.round ELSE #{LEVELS} END"
      .freeze
  # How many of a deck's rows (cards, or a language deck's entries) there
  # are, how many are finished and how many seen sit at each level; the
  # rest are new.
  PROGRESS_FILTERS = {
    "total" => "TRUE",
    "done" => "rows.correct_streak >= %<finish>s",
    "level1" => "rows.correct_streak = 0 AND rows.view_count > 0",
    "level2" => "rows.correct_streak = 1",
    "level3" => "rows.correct_streak = 2",
  }.freeze
  # One count's SQL, given the streak a row is finished at.
  PROGRESS_COUNT =
    ->(filter, finish) { "COUNT(*) FILTER (WHERE #{format(filter, finish:)})" }
  PROGRESS_SELECTS =
    PROGRESS_FILTERS.map do |name, filter|
      "#{PROGRESS_COUNT.call(filter, FINISH_STREAK)} AS #{name}"
    end

  # A language deck's cards are the entries its list selects, each scored
  # by the weakest of the owner's skill_scores on the entry's senses, and a
  # guest's deck stops at
  # the first GUEST_CARD_LIMIT of them in list order. Only reading decks
  # exist, so the skill is fixed here until 4.7. Senses are looked up one
  # by one (OFFSET 0 keeps the planner from flattening it), since otherwise
  # it reads every sense in the compendium for each deck.
  LANGUAGE_ENTRIES = <<~SQL.squish
    SELECT MIN(COALESCE(skill_scores.correct_streak, 0)) AS correct_streak,
      MIN(COALESCE(skill_scores.view_count, 0)) AS view_count,
      ROW_NUMBER() OVER (ORDER BY MIN(sense_memberships.position)) AS list_row
    FROM sense_memberships
    JOIN LATERAL (
      SELECT senses.id, senses.entry_id FROM senses
      WHERE senses.id = sense_memberships.sense_id OFFSET 0
    ) senses ON TRUE
    LEFT JOIN skill_scores ON skill_scores.sense_id = senses.id
      AND skill_scores.user_id = decks.user_id
      AND skill_scores.skill = 'reading'
    WHERE sense_memberships.word_list_id = decks.word_list_id
    GROUP BY senses.entry_id
  SQL
  # Every count comes from one pass over the entries, since grouping them
  # is the costly part.
  PROGRESS = <<~SQL.squish
    JOIN LATERAL (
      SELECT #{PROGRESS_SELECTS.join(", ")}
      FROM cards rows WHERE rows.deck_id = decks.id
    ) flat_progress ON TRUE
    JOIN LATERAL (
      SELECT #{PROGRESS_SELECTS.join(", ")}
      FROM (#{LANGUAGE_ENTRIES}) rows
      WHERE users.role <> 'guest' OR rows.list_row <= :card_limit
    ) language_progress ON TRUE
  SQL
  # A deck has cards or entries, never both, so the other side counts 0.
  PROGRESS_COLUMNS = <<~SQL.squish
    decks.*,
    flat_progress.total + language_progress.total AS cards_count,
    flat_progress.done + language_progress.done AS done_count,
    flat_progress.level1 + language_progress.level1 AS level1_count,
    flat_progress.level2 + language_progress.level2 AS level2_count,
    flat_progress.level3 + language_progress.level3 AS level3_count
  SQL
  # A list's entries, counted without anyone's progress, for the catalog.
  ENTRY_COUNT_FROM = <<~SQL.squish
    SELECT COUNT(DISTINCT senses.entry_id) FROM sense_memberships
    JOIN senses ON senses.id = sense_memberships.sense_id
  SQL
  ENTRY_COUNT_COLUMNS = <<~SQL.squish
    decks.*,
    CASE WHEN decks.word_list_id IS NULL THEN
      (SELECT COUNT(*) FROM cards WHERE cards.deck_id = decks.id)
    ELSE
      (#{ENTRY_COUNT_FROM}
        WHERE sense_memberships.word_list_id = decks.word_list_id)
    END AS cards_count
  SQL

  # Round targets gave way to target dates; dropped once this is deployed.
  self.ignored_columns += ["target_round"]

  belongs_to :word_list
  belongs_to :user
  # A target date's last chapter; none means the whole deck.
  belongs_to :target_snippet, class_name: "Snippet"
  belongs_to :source_deck, class_name: "Deck"
  has_many :cards, dependent: :delete_all
  has_one :source, through: :word_list
  has_many :snippets, through: :source
  has_many :study_days, dependent: :delete_all
  has_one :todays_study_day,
          -> { where(studied_on: Date.current) },
          class_name: "StudyDay",
          inverse_of: :deck,
          dependent: nil

  # A deck with no row today hasn't been studied yet, so it can't have met
  # its goal. Music decks have no study goal.
  def self.goal_unmet_today
    with_goal = left_joins(:todays_study_day)
      .where.not(goal_mode: "none")
      .where.not(type: MusicDeck.name)
    with_goal.where(study_days: { id: nil }).or(with_goal.where(GOAL_UNMET))
  end

  def self.progress_joins
    sanitize_sql_array([PROGRESS, { card_limit: GUEST_CARD_LIMIT }])
  end

  # Flat-card decks own their name (the column); language decks override the
  # reader to go through the word_list.
  def language = nil

  attribute(:round, :integer, default: 1)
  attribute(:visibility, :string, default: "private")
  attribute(:script, :string, default: "simplified")

  before_validation(:clear_target, unless: :target_mode?)

  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :distractor_pool, inclusion: { in: DISTRACTOR_POOLS }
  validates :study_goal,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :goal_mode, inclusion: { in: GOAL_MODES }
  validates :target_date, presence: true, if: :target_mode?
  # Checked only when set, so a deck that outlives its date can still be
  # saved.
  validates :target_date,
            comparison: { greater_than_or_equal_to: -> { Date.current } },
            allow_nil: true,
            if: :will_save_change_to_target_date?
  validates :name,
            presence: true,
            uniqueness: { scope: :user_id },
            if: :flat_cards?
  validates :word_list, presence: true, unless: :flat_cards?
  validates :word_list, absence: true, if: :flat_cards?
  validate(:one_deck_per_word_list, unless: :flat_cards?)
  validate(
    :target_snippet_of_source,
    if: :will_save_change_to_target_snippet_id?,
  )

  scope :ordered, -> { left_joins(:word_list).order(NAME_SOURCE) }
  scope :publicly_visible, -> { where(visibility: "public") }
  scope :with_progress,
        -> { joins(:user).joins(progress_joins).select(PROGRESS_COLUMNS) }
  scope :with_entry_counts, -> { select(ENTRY_COUNT_COLUMNS) }

  def music? = false

  def name_translation = source&.title_translation.presence

  def cards_count = self[:cards_count] || progress.total
  def done_count = self[:done_count] || progress.done
  def remaining_count = cards_count - done_count

  # Its words at a level (1 to LEVELS) that have been seen.
  def level_count(level)
    name = "level#{level}"
    self[:"#{name}_count"] || progress.public_send(name)
  end

  def new_count
    cards_count - done_count - (1..LEVELS).sum { level_count(it) }
  end

  # The streak at which a card is done: a word's last level, or for Music
  # the deck's round.
  def finish_streak = LEVELS

  def reload(*)
    @progress = nil
    @target_work_left = nil
    super
  end

  def card_limit = (GUEST_CARD_LIMIT if user.guest?)

  # Whether this family's cards own their content directly (the flat-card
  # model); language decks read the compendium through their word_list.
  def flat_cards? = false

  # Whether the deck's content can be replaced from a fresh CSV; only Basic
  # decks support it.
  def replaceable? = false

  def generates_distractors? = distractor_pool == "category"

  def card(id) = cards.find(id)

  def finished_snippets = snippets.select { it.status == :finished }

  # What the Read tab shows the deck's owner.
  def readable_snippets
    finished_snippets.select { it.source.readable_by?(user) }
  end

  def shares_texts?
    source.present? && source.shareable? && source.studyable?
  end

  # A streak climbs once a day, so a card answered correctly today waits for
  # tomorrow; practice studies just those cards. The highest level comes
  # first, each level in the deck's order.
  def study_pool(limit:, practice: false)
    pool = cards.not_done(finish_streak)
    pool = practice ? pool.correct_today : pool.not_correct_today
    pool.order(correct_streak: :desc).ordered.limit(limit).to_a
  end

  # Cards left to finish, but every one answered correctly today.
  def waiting_for_tomorrow? = !all_done? && nothing_to_study?

  def nothing_to_study? = study_pool(limit: 1).empty?

  def all_done? = progress.done == progress.total

  def target_mode? = goal_mode == "target"

  def no_goal? = goal_mode == "none"

  def target_active? = target_mode? && target_work_left.positive?

  def target_missed? = target_active? && target_date < Date.current

  def target_reached? = target_mode? && target_work_left.zero?

  # The steps left to finish the target.
  def target_work_left
    @target_work_left ||=
      Deck.unscoped.from(target_rows, :rows).pick(STEPS_LEFT) || 0
  end

  # What a target date aims to finish: the deck, or its text up to a
  # chapter.
  def target_label = target_snippet&.label || "the deck"

  # The steps left to finish the target, spread over the days left
  # including today. A passed date puts everything left on today.
  def target_goal
    return unless target_active?

    days_left = [(Date.current..target_date).count, 1].max
    target_work_left.fdiv(days_left).ceil
  end

  # Tomorrow's goal: the work left spread over the days after today, so
  # studying past today's goal lowers it. Nil without a day after today.
  def next_target_goal
    return unless target_active? && days_after_today.positive?

    target_work_left.fdiv(days_after_today).ceil
  end

  # Steps that lower tomorrow's goal by one: a card for each day
  # after today, which keeps every batch the same size. With no day after
  # today, or less work left than that, it is all the work left.
  def cards_to_lower_goal
    return unless target_active?
    return target_work_left unless days_after_today.positive?

    [days_after_today, target_work_left].min
  end

  def backs(except: nil, category: nil)
    scope = category ? cards_in_category(category) : cards
    scope = scope.where.not(id: except.id) if except
    scope.backs
  end

  def cards_in_order(limit: nil)
    limit ? cards.ordered.limit(limit) : cards.ordered
  end

  # Sibling (front, reading) pairs for the reading stage's decoy pool; the
  # study engine filters and ranks them.
  def reading_pairs(except:)
    cards.where.not(id: except.id).pluck(:front, :reading)
  end

  def readings?
    cards.where.not(reading: [nil, ""]).exists?
  end

  # Gates the study page's Mandarin font menu; only language decks can be.
  def mandarin? = false

  def publicly_visible? = visibility == "public"

  def shared? = share_token.present?

  def generate_share_token!
    update!(share_token: SecureRandom.urlsafe_base64(16))
  end

  def revoke_share_token!
    update!(share_token: nil)
  end

  private

  # Every count comes from one query, kept per finish streak: a study page
  # asks for them several times, and a music deck's new round mid-request
  # counts afresh.
  def progress
    @progress ||= {}
    @progress[finish_streak] ||= Progress.new(*count_progress)
  end

  def count_progress
    counts =
      PROGRESS_FILTERS.values.map do |filter|
        Arel.sql(PROGRESS_COUNT.call(filter, finish_streak))
      end
    Deck.unscoped.from(progress_rows, :rows).pick(*counts)
  end

  def progress_rows = cards

  def clear_target
    self.target_date = nil
    self.target_snippet = nil
  end

  # The rows a target date covers; LanguageDeck narrows them to a chapter.
  def target_rows = progress_rows

  def target_snippet_of_source
    return if target_snippet.nil? || target_snippet.source == source

    errors.add(:target_snippet, "must be from the deck's text")
  end

  def days_after_today = (Date.tomorrow..target_date).count

  # Cards whose studied answer carries the given category, for category-pool
  # distractors. Flat-card families read the card column; language decks
  # override to look through the item layer.
  def cards_in_category(category)
    cards.where(category:)
  end

  # Language decks reference a shared word_list rather than copying it, so
  # adding the same catalog deck twice would otherwise leave a user with two
  # identical decks. Scoped by type so a future writing deck can sit
  # alongside its reading counterpart.
  def one_deck_per_word_list
    return if word_list_id.blank?

    sibling = Deck.where(user_id:, word_list_id:, type:).where.not(id:)
    return unless sibling.exists?

    errors.add(:base, "This deck is already in your decks")
  end
end
