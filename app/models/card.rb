# frozen_string_literal: true

class Card < ApplicationRecord
  belongs_to :deck

  STATUSES = ["pending", "active", "done"].freeze

  validates :deck_id, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :front, presence: true, uniqueness: { scope: :deck_id }
  validates :back, presence: true
  validates :category, presence: true
  validates :correct_count, presence: true
  validates :correct_streak, presence: true
  validates :view_count, presence: true

  scope :active, -> { where(status: "active") }
  scope :done, -> { where(status: "done") }
  scope :pending, -> { where(status: "pending") }
  scope :ordered, -> { order(:id) }
end
