# frozen_string_literal: true

# The forward study of a language data_set: recognize the target-language
# prompt and recall its meaning.
class ReadingDeck < LanguageDeck
  def card_type = "ReadingCard"

  def type_label = "Reading"

  def reversible? = true

  def replaceable? = true
end
