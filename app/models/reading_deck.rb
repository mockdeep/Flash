# frozen_string_literal: true

# The forward study of a word_list: recognize the target-language
# prompt and recall its meaning.
class ReadingDeck < LanguageDeck
  def card_type = "ReadingCard"

  def type_label = "Reading"
end
