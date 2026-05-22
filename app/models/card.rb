# frozen_string_literal: true

class Card < ApplicationRecord
  self.ignored_columns += ["status"]

  belongs_to :deck
  belongs_to :source_card, class_name: "Card", optional: true
  has_many :suggestions, class_name: "CardSuggestion", dependent: :destroy

  validates :deck_id, presence: true
  validates :front, presence: true, uniqueness: { scope: :deck_id }
  validates :back, presence: true
  validates :category, presence: true
  validates :correct_count, presence: true
  validates :correct_streak, presence: true
  validates :view_count, presence: true

  scope :done, ->(level) { where(correct_streak: level..) }
  scope :not_done, ->(level) { where(correct_streak: ...level) }
  scope :ordered, -> { order(:id) }

  def done? = correct_streak >= deck.level

  def suggestable_to_catalog?
    return false unless source_card

    source_card.deck.visibility == "public" &&
      source_card.deck.user_id != deck.user_id
  end
end
