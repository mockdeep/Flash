# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private"].freeze
  DISTRACTOR_POOLS = ["category", "preset", "none"].freeze
  NAME_SOURCE = Arel.sql("COALESCE(decks.name, word_lists.name)")
  GUEST_CARD_LIMIT = 100

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
        WHERE cards.deck_id = decks.id AND cards.correct_streak >= decks.level)
    ELSE
      (SELECT COUNT(*) FROM (#{LANGUAGE_ENTRIES}) entries
        WHERE (users.role <> 'guest' OR entries.list_row <= :card_limit)
          AND entries.correct_streak >= decks.level)
    END AS done_count
  SQL

  belongs_to :word_list
  belongs_to :user
  belongs_to :topic
  has_many :cards, dependent: :delete_all

  def self.progress_columns
    sanitize_sql_array([PROGRESS_COLUMNS, { card_limit: GUEST_CARD_LIMIT }])
  end

  # Flat-card decks own their name (the column); language decks override the
  # reader to go through the word_list.
  def language = nil

  attribute(:level, :integer, default: 1)
  attribute(:visibility, :string, default: "private")

  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :distractor_pool, inclusion: { in: DISTRACTOR_POOLS }
  validates :study_goal,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :name,
            presence: true,
            uniqueness: { scope: :user_id },
            if: :flat_cards?
  validates :word_list, presence: true, unless: :flat_cards?
  validates :word_list, absence: true, if: :flat_cards?
  validate(:one_deck_per_word_list, unless: :flat_cards?)

  scope :ordered, -> { left_joins(:word_list).order(NAME_SOURCE) }
  scope :publicly_visible, -> { where(visibility: "public") }
  scope :with_progress, -> { joins(:user).select(progress_columns) }

  def music? = false

  def cards_count = self[:cards_count] || cards.count
  def done_count = self[:done_count] || cards.done(level).count
  def remaining_count = cards_count - done_count

  def card_limit = (GUEST_CARD_LIMIT if user.guest?)

  # Whether this family's cards own their content directly (the flat-card
  # model); language decks read the compendium through their word_list.
  def flat_cards? = false

  # Whether the deck's content can be replaced from a fresh CSV; only Basic
  # decks support it.
  def replaceable? = false

  def generates_distractors? = distractor_pool == "category"

  def card(id) = cards.find(id)

  def study_pool(limit:) = cards.not_done(level).ordered.limit(limit).to_a

  def all_done? = cards.not_done(level).none?

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
