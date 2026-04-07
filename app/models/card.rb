# frozen_string_literal: true

class Card < ApplicationRecord
  self.ignored_columns += ["status"]

  belongs_to :deck

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
end
