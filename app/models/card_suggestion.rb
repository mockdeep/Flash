# frozen_string_literal: true

class CardSuggestion < ApplicationRecord
  STATES = ["pending", "accepted", "rejected"].freeze

  belongs_to :card
  belongs_to :user

  attribute(:state, :string, default: "pending")

  validates :front, presence: true
  validates :back, presence: true
  validates :category, presence: true
  validates :state, inclusion: { in: STATES }

  scope :pending, -> { where(state: "pending") }
end
