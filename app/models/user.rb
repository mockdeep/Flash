# frozen_string_literal: true

class User < ApplicationRecord
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP.freeze

  has_secure_password

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :username, with: ->(username) { username.to_s.strip }

  validates :email, presence: true, format: EMAIL_REGEXP, uniqueness: true
  validates :username,
            presence: true,
            uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_]+\z/ }

  has_many :decks, dependent: :destroy
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
    false
  end
end
