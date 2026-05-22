# frozen_string_literal: true

class User < ApplicationRecord
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP.freeze
  ROLES = ["user", "admin", "guest"].freeze

  has_secure_password

  attribute(:study_goal, :integer, default: 50)

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :username, with: ->(username) { username.to_s.strip }

  validates :role, inclusion: { in: ROLES }
  validates :email, presence: true, format: EMAIL_REGEXP, uniqueness: true
  validates :username,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_.]+\z/ }
  validates :study_goal,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }

  has_many :decks, dependent: :destroy
  has_many :card_suggestions, dependent: :destroy
  has_one :subscription, dependent: :destroy

  def self.find_by(args)
    super || NullUser.new
  end

  def self.find_by!(args)
    super.presence || raise(ActiveRecord::RecordNotFound)
  end

  def logged_in?
    true
  end

  def admin?
    role == "admin"
  end

  def guest?
    role == "guest"
  end

  def supporter?
    subscription&.active? || false
  end
end
