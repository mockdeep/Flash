# frozen_string_literal: true

class Deck < ApplicationRecord
  VISIBILITIES = ["public", "private"].freeze
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

  def music? = false

  def shared? = share_token.present?

  def generate_share_token!
    update!(share_token: SecureRandom.urlsafe_base64(16))
  end

  def revoke_share_token!
    update!(share_token: nil)
  end
end
