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

  def cards_in_category(category)
    cards.joins(:item).where(items: { category: })
  end

  def reading_pairs(except:)
    cards.where.not(id: except.id)
      .joins(item: :entry).pluck("entries.headword", "entries.reading")
  end

  def readings?
    cards.joins(item: :entry).where.not(entries: { reading: [nil, ""] }).exists?
  end

  def hanzi_chars
    @hanzi_chars ||=
      word_list.entries.pluck(:headword).join.scan(/\p{Han}/).uniq.join
  end
end
