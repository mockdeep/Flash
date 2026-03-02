# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private", "demo"].freeze

  belongs_to :user
  has_many :cards, dependent: :delete_all

  attribute(:visibility, :string, default: "private")

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :visibility, inclusion: { in: VISIBILITIES }

  scope :publicly_visible, -> { where(visibility: "public") }
  scope :demo_visible, -> { where(visibility: "demo") }
end
