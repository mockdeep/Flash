# frozen_string_literal: true

class DataSet < ApplicationRecord
  # Languages with dedicated study-page treatment (fonts, prewarming). Grows as
  # the app supports more scripts; nil means plain text with default styling.
  LANGUAGES = ["zh"].freeze

  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :decks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :language, inclusion: { in: LANGUAGES }, allow_nil: true

  # Derives language from the item text at ingest; after that the column is
  # the reference point for language-specific features, not the content.
  # Items arrive via insert_all, so reset the association before reading it.
  def detect_language!
    detected = items.reset.pluck(:text).join.match?(/\p{Han}/) ? "zh" : nil
    update!(language: detected) unless language == detected
  end
end
