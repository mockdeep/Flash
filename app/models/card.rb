# frozen_string_literal: true

class Card < ApplicationRecord
  self.ignored_columns += ["status"]

  # Edit validation adds errors keyed to content fields that now live on
  # data_set items, not card columns. ActiveModel reads the attribute to build
  # the error message, so resolve these virtual keys to nil instead of raising.
  CONTENT_FIELDS = [
    :front, :back, :category, :reading, :example_front, :example_back
  ].freeze

  belongs_to :deck
  belongs_to :item
  belongs_to :source_card, class_name: "Card"
  has_many :suggestions, class_name: "CardSuggestion", dependent: :destroy

  validates :deck_id, presence: true
  validates :correct_count, presence: true
  validates :correct_streak, presence: true
  validates :view_count, presence: true

  scope :done, ->(level) { where(correct_streak: level..) }
  scope :not_done, ->(level) { where(correct_streak: ...level) }
  scope :ordered, -> { order(:id) }

  def done? = correct_streak >= deck.level

  def read_attribute_for_validation(key)
    CONTENT_FIELDS.include?(key.to_sym) ? nil : super
  end

  def suggestable_to_catalog?
    return false unless source_card

    source_card.deck.visibility == "public" &&
      source_card.deck.user_id != deck.user_id
  end
end
