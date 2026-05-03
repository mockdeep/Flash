# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private", "demo"].freeze
  DISTRACTOR_POOLS = ["category", "preset", "none"].freeze

  belongs_to :user
  has_many :cards, dependent: :delete_all

  attribute(:level, :integer, default: 1)
  attribute(:visibility, :string, default: "private")

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :visibility, inclusion: { in: VISIBILITIES }
  validates :distractor_pool, inclusion: { in: DISTRACTOR_POOLS }
  validates :study_goal,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :ordered, -> { order(:name) }
  scope :publicly_visible, -> { where(visibility: "public") }
  scope :demo_visible, -> { where(visibility: "demo") }
end
