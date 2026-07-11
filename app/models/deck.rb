# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private"].freeze
  DISTRACTOR_POOLS = ["category", "preset", "none"].freeze

  belongs_to :data_set, optional: false
  has_many :cards, dependent: :delete_all
  has_many :incoming_suggestions, through: :cards, source: :suggestions

  delegate :name, :user, :user_id, :language, :topic, to: :data_set

  attribute(:level, :integer, default: 1)
  attribute(:visibility, :string, default: "private")

  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :distractor_pool, inclusion: { in: DISTRACTOR_POOLS }
  validates :study_goal,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validate(:data_set_name_valid, if: -> { data_set&.new_record? })
  validate(:type_allowed_by_data_set)

  scope :ordered, -> { joins(:data_set).order("data_sets.name") }
  scope :publicly_visible, -> { where(visibility: "public") }

  def music? = false

  # The item side a deck's cards anchor to (and study as the prompt). A reverse
  # deck flips this to "Back"; the projection reconciles each deck's cards to
  # the paired items on its anchor side.
  def anchor_side = "Front"

  # The pairing column whose values are this deck's anchor items (the side it
  # studies as the answer's counterpart). Mirrors #anchor_side.
  def anchor_pairing_column = :item_id

  def reversible? = false

  # Whether the deck's content can be replaced from a fresh CSV; only the
  # forward text decks support it.
  def replaceable? = false

  # Whether a reverse deck already exists over this deck's data_set (one per
  # source); used to guard creation and hide the create button.
  def reverse_present?
    data_set.present? && data_set.decks.exists?(type: "WritingDeck")
  end

  # Cards whose studied answer carries the given category, for category-pool
  # distractors. Forward decks read it off the anchored Front item; a reverse
  # deck overrides this to look through the pairing to the answer item.
  def cards_in_category(category)
    cards.joins(:item).where(items: { category: })
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

  def data_set_name_valid
    errors.merge!(data_set.errors) unless data_set.valid?
  end

  def type_allowed_by_data_set
    return if data_set.nil? || data_set.deck_classes.include?(self.class)

    errors.add(:type, "can't be built on a #{data_set.class.name}")
  end
end
