# frozen_string_literal: true

# A section of a page of decks (a user's, or the catalog's), worked out from
# what the decks are: one per language A-Z, then Basic, then Music. Built
# from the decks given, so no section is ever empty.
DeckSection = Data.define(:name, :decks)

class DeckSection
  FAMILIES = { "BasicDeck" => "Basic", "MusicDeck" => "Music" }.freeze

  def self.for(decks)
    language_sections(decks) + family_sections(decks)
  end

  def self.language_sections(decks)
    lists = WordList.where(id: decks.select(:word_list_id))
    sections =
      lists.distinct.pluck(:language).map do |language|
        language_decks = decks.where(word_list: WordList.where(language:))
        new(name: WordList::LANGUAGES[language], decks: language_decks)
      end
    sections.sort_by(&:name)
  end

  def self.family_sections(decks)
    FAMILIES.filter_map do |type, name|
      family_decks = decks.where(type:)
      new(name:, decks: family_decks) if family_decks.exists?
    end
  end

  def anchor = name.parameterize

  # A source's decks share a card, so they count once.
  def card_count
    decks.where(word_list_id: nil).count + decks.distinct.count(:word_list_id)
  end

  # The first deck in page order still short of today's goal.
  def first_unmet = decks.goal_unmet_today.ordered.first
end
