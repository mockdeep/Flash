# frozen_string_literal: true

class User < ApplicationRecord
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP.freeze

  has_secure_password

  normalizes :email, with: ->(email) { email.to_s.strip.downcase }

  validates :email, presence: true, format: EMAIL_REGEXP, uniqueness: true

  has_many :decks

  def self.find_by(args)
    super || NullUser.new
  end

  def self.find(id)
    id ? super : NullUser.new
  end

  def logged_in?
    true
  end

  def admin?
    false
  end
end
