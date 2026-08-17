# frozen_string_literal: true

# Shared behavior for decks over a word_list: one class per language skill
# (Reading, Writing; someday Listening, Speaking). Never instantiated
# directly.
class LanguageDeck < Deck
  def self.model_name
    Deck.model_name
  end

  delegate :name, :language, to: :word_list

  def mandarin? = language == "zh"

  # Language card content still lives on word_list items, so the category and
  # reading lookups join through the item. The reverse deck overrides
  # cards_in_category again to reach the answer-side item.
  def cards_in_category(category)
    cards.joins(:item).where(items: { category: })
  end

  def reading_pairs(except:)
    cards.where.not(id: except.id)
      .joins(:item).pluck("items.text", "items.reading")
  end

  # The distinct Han characters across the word_list's items; the study page
  # embeds them once so the browser can prewarm the font slices they need.
  def hanzi_chars
    @hanzi_chars ||= word_list.items.pluck(:text).join.scan(/\p{Han}/).uniq.join
  end
end
