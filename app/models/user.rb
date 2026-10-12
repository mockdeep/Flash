# frozen_string_literal: true

class User < ApplicationRecord
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP.freeze
  ROLES = ["user", "admin", "guest"].freeze

  has_secure_password

  VALID_TIME_ZONES = TZInfo::Timezone.all_identifiers.freeze

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
  validates :time_zone, inclusion: { in: VALID_TIME_ZONES }

  has_many :decks, dependent: :destroy
  has_many :word_lists, dependent: :destroy
  has_many :sources, through: :word_lists
  has_many :topics, dependent: :destroy
  has_many :sense_distractors, dependent: :delete_all
  has_many :skill_scores, dependent: :delete_all
  has_many :source_readers, dependent: :delete_all
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

  def next_unmet_deck = decks.goal_unmet_today.topic_ordered.first

  def reading_deck_over(word_list)
    decks.create_with(distractor_pool: "category", study_goal:)
      .find_or_create_by!(type: "ReadingDeck", word_list:)
  end

  def supporter?
    subscription&.active? || false
  end
end
