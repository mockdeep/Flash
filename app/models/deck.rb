# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private"].freeze
  DISTRACTOR_POOLS = ["category", "preset", "none"].freeze
  GOAL_MODES = ["none", "session", "target"].freeze
  NAME_SOURCE = Arel.sql("COALESCE(decks.name, word_lists.name)")
  # Mirrors StudyDay#study_goal.
  GOAL_UNMET = <<~SQL.squish
    study_days.completed_count <
      CASE WHEN decks.goal_mode = 'target' AND decks.round <= decks.target_round
        THEN study_days.goal
        ELSE decks.study_goal
      END
  SQL
  GUEST_CARD_LIMIT = 100
  Progress = Data.define(:total, :done)

  # A language deck's cards are the entries its list selects, each scored by
  # the weakest of the owner's skill_scores on the entry's senses, and a
  # guest's deck stops at the first GUEST_CARD_LIMIT of them in list order.
  # Only reading decks exist, so the skill is fixed here until 4.7.
  LANGUAGE_ENTRIES = <<~SQL.squish
    SELECT MIN(COALESCE(skill_scores.correct_streak, 0)) AS correct_streak,
      ROW_NUMBER() OVER (ORDER BY MIN(sense_memberships.position)) AS list_row
    FROM sense_memberships
    JOIN senses ON senses.id = sense_memberships.sense_id
    LEFT JOIN skill_scores ON skill_scores.sense_id = senses.id
      AND skill_scores.user_id = decks.user_id
      AND skill_scores.skill = 'reading'
    WHERE sense_memberships.word_list_id = decks.word_list_id
    GROUP BY senses.entry_id
  SQL
  PROGRESS_COLUMNS = <<~SQL.squish
    decks.*,
    CASE WHEN decks.word_list_id IS NULL THEN
      (SELECT COUNT(*) FROM cards WHERE cards.deck_id = decks.id)
    ELSE
      (SELECT COUNT(*) FROM (#{LANGUAGE_ENTRIES}) entries
        WHERE users.role <> 'guest' OR entries.list_row <= :card_limit)
    END AS cards_count,
    CASE WHEN decks.word_list_id IS NULL THEN
      (SELECT COUNT(*) FROM cards
        WHERE cards.deck_id = decks.id AND cards.correct_streak >= decks.round)
    ELSE
      (SELECT COUNT(*) FROM (#{LANGUAGE_ENTRIES}) entries
        WHERE (users.role <> 'guest' OR entries.list_row <= :card_limit)
          AND entries.correct_streak >= decks.round)
    END AS done_count
  SQL

  belongs_to :word_list
  belongs_to :user
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

  def self.progress_columns
    sanitize_sql_array([PROGRESS_COLUMNS, { card_limit: GUEST_CARD_LIMIT }])
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
  validates :target_round, :target_date, presence: true, if: :target_mode?
  # Checked only when set, so a deck that moves on past its target or
  # outlives its date can still be saved.
  validates :target_round,
            numericality: {
              greater_than_or_equal_to: :round,
              only_integer: true,
            },
            allow_nil: true,
            if: :will_save_change_to_target_round?
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

  scope :ordered, -> { left_joins(:word_list).order(NAME_SOURCE) }
  scope :publicly_visible, -> { where(visibility: "public") }
  scope :recently_studied,
        -> { where.not(last_studied_at: nil).reorder(last_studied_at: :desc) }
  scope :with_progress, -> { joins(:user).select(progress_columns) }

  def music? = false

  def name_translation = source&.title_translation

  def cards_count = self[:cards_count] || progress.total
  def done_count = self[:done_count] || progress.done
  def remaining_count = cards_count - done_count

  def reload(*)
    @progress = nil
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

  def finished_snippets
    snippets.select { |snippet| snippet.status == :finished }
  end

  def shares_texts? = finished_snippets.any? && source.shareable?

  def study_pool(limit:) = cards.not_done(round).ordered.limit(limit).to_a

  def all_done? = progress.done == progress.total

  # Progress is shared between a user's decks, so a deck can open with every
  # card done at its round; it moves on to the first round with work left.
  def catch_up_round!
    lowest = lowest_streak
    update!(round: lowest + 1) if lowest && lowest >= round
  end

  def not_done_count(at_round) = cards.not_done(at_round).count

  def target_mode? = goal_mode == "target"

  def no_goal? = goal_mode == "none"

  def target_active? = target_mode? && round <= target_round

  def target_missed? = target_active? && target_date < Date.current

  def target_reached? = target_mode? && round > target_round

  # Card completions left to finish the target round, spread over the days
  # left including today. A passed date puts everything left on today.
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

  # Card completions that lower tomorrow's goal by one: a card for each day
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

  # Total and done cards come from one query, kept per round: a study page
  # asks for them several times, and a new round mid-request counts afresh.
  def progress
    @progress ||= {}
    @progress[round] ||= Progress.new(*count_progress)
  end

  def count_progress = cards.pick(*progress_counts)

  def lowest_streak = cards.minimum(:correct_streak)

  def progress_counts
    done = ["COUNT(*) FILTER (WHERE correct_streak >= ?)", round]
    [Arel.sql("COUNT(*)"), Arel.sql(self.class.sanitize_sql_array(done))]
  end

  def clear_target
    self.target_round = nil
    self.target_date = nil
  end

  def target_work_left = (round..target_round).sum { |at| not_done_count(at) }

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
