# frozen_string_literal: true

# The forward study of a language data_set: recognize the target-language
# prompt and recall its meaning.
class ReadingDeck < LanguageDeck
  def reversible? = true

  def replaceable? = true
end
