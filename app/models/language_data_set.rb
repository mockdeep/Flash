# frozen_string_literal: true

class LanguageDataSet < DataSet
  # Codes ISO 639-2 reserves for non-languages (undetermined, no linguistic
  # content, local use); collective families ("Bantu languages") are filtered
  # by name below.
  SPECIAL_CODES = ["und", "zxx", "qaa-qtz"].freeze

  # Every individual ISO 639-2 language, code => display name, keyed by the
  # shortest available code (BCP 47 convention: "zh", not "zho") so stored
  # values work as language tags for future speech features. User-selected at
  # creation. Only zh gets dedicated study-page treatment (fonts, prewarming)
  # so far.
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

  validates :language, presence: true, inclusion: { in: LANGUAGES.keys }

  def deck_classes = [ReadingDeck, WritingDeck]
end
