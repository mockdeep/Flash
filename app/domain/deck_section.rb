# frozen_string_literal: true

# A section of a page of decks (a user's, or the catalog's), worked out from
# what the decks are: one per language A-Z, then Basic, then Music. Built
# from the decks given, and on the catalog the sources listed there, so no
# section is ever empty.
DeckSection = Data.define(:name, :decks, :sources)

class DeckSection
  FAMILIES = { "BasicDeck" => "Basic", "MusicDeck" => "Music" }.freeze

  def self.for(decks, sources: Source.none)
    language_sections(decks, sources) + family_sections(decks)
  end

  def self.language_sections(decks, sources)
    lists = WordList.where(id: decks.select(:word_list_id))
      .or(WordList.where(id: sources.select(:word_list_id)))
    languages = lists.distinct.pluck(:language)
    sections = languages.map { language_section(it, decks, sources) }
    sections.sort_by(&:name)
  end

  def self.language_section(language, decks, sources)
    in_language = WordList.where(language:)
    new(
      name: WordList::LANGUAGES[language],
      decks: decks.where(word_list: in_language),
      sources: sources.where(word_list: in_language),
    )
  end

  def self.family_sections(decks)
    FAMILIES.filter_map do |type, name|
      family_decks = decks.where(type:)
      new(name:, decks: family_decks) if family_decks.exists?
    end
  end

  def initialize(name:, decks:, sources: Source.none) = super

  def anchor = name.parameterize

  # A source's decks share a card, so they count once.
  def card_count
    decks.where(word_list_id: nil).count +
      decks.distinct.count(:word_list_id) + sources.count
  end

  # The first deck in page order still short of today's goal, and not
  # waiting for tomorrow.
  def first_unmet
    decks.goal_unmet_today.ordered.find { !it.waiting_for_tomorrow? }
  end
end
