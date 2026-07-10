# frozen_string_literal: true

# Shared behavior for decks over a LanguageDataSet: one class per language
# skill (Reading, Writing; someday Listening, Speaking). Never instantiated
# directly.
class LanguageDeck < Deck
  def self.model_name
    Deck.model_name
  end

  def mandarin? = language == "zh"

  # The distinct Han characters across the data_set's items; the study page
  # embeds them once so the browser can prewarm the font slices they need.
  def hanzi_chars
    @hanzi_chars ||= data_set.items.pluck(:text).join.scan(/\p{Han}/).uniq.join
  end
end
