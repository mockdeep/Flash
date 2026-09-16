# frozen_string_literal: true

# The forward study of a word_list: recognize the target-language
# prompt and recall its meaning.
class ReadingDeck < LanguageDeck
  def type_label = "Reading"

  def skill = "reading"
end
