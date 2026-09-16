# frozen_string_literal: true

# The forward study of a word_list: recognize the target-language
# prompt and recall its meaning.
class ReadingDeck < LanguageDeck
  has_many :cards, class_name: "ReadingCard", dependent: :delete_all

  def card_type = "ReadingCard"

  def type_label = "Reading"

  def skill = "reading"
end
