# frozen_string_literal: true

# A selection of study content that decks point at. Basic and Music moved to
# flat deck-owned cards, so every word_list is a language list; the compendium
# distinguishes kinds (HSK level, chapter, curated) by column, not by class.
class WordList < ApplicationRecord
  # Codes ISO 639-2 reserves for non-languages (undetermined, no linguistic
  # content, local use); collective families ("Bantu languages") are filtered
  # by name below.
  SPECIAL_CODES = ["und", "zxx", "qaa-qtz"].freeze

  # Every individual ISO 639-2 language, code => display name, keyed by the
  # shortest available code (BCP 47 convention: "zh", not "zho") so stored
  # values work as language tags for future speech features. Nothing in the
  # app creates a word_list any more, so this validates what the seed account
  # and catalog copies carry. Only zh gets dedicated study-page treatment
  # (fonts, prewarming) so far.
  language_pairs =
    ISO_639::ISO_639_2.filter_map do |entry|
      name = entry.english_name.split(";").first
      next if SPECIAL_CODES.include?(entry.alpha3) ||
        name.match?(/languages/i)

      [entry.alpha2.presence || entry.alpha3, name]
    end
  LANGUAGES = language_pairs.sort_by(&:last).to_h.freeze

  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :decks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :language, presence: true, inclusion: { in: LANGUAGES.keys }
end
