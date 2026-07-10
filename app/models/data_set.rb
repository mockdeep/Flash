# frozen_string_literal: true

class DataSet < ApplicationRecord
  # Codes ISO 639-2 reserves for non-languages (undetermined, no linguistic
  # content, local use); collective families ("Bantu languages") are filtered
  # by name below.
  SPECIAL_CODES = ["und", "zxx", "qaa-qtz"].freeze

  # Every individual ISO 639-2 language, code => display name, keyed by the
  # shortest available code (BCP 47 convention: "zh", not "zho") so stored
  # values work as language tags for future speech features. User-selected at
  # creation; nil means plain text. Only zh gets dedicated study-page
  # treatment (fonts, prewarming) so far.
  language_pairs =
    ISO_639::ISO_639_2.filter_map do |entry|
      name = entry.english_name.split(";").first
      next if SPECIAL_CODES.include?(entry.alpha3) ||
        name.match?(/languages/i)

      [entry.alpha2.presence || entry.alpha3, name]
    end
  LANGUAGES = language_pairs.sort_by(&:last).to_h.freeze

  # Promoted to the top of the deck form's language select.
  COMMON_LANGUAGE_CODES = [
    "ar",
    "zh",
    "fr",
    "de",
    "hi",
    "it",
    "ja",
    "ko",
    "pt",
    "ru",
    "es",
  ].freeze

  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :decks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :language, inclusion: { in: LANGUAGES.keys }, allow_nil: true
end
