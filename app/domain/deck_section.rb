# frozen_string_literal: true

# A section of the decks page, worked out from what the decks are: one per
# language A-Z, then Basic, then Music. Built from the decks a user has, so
# no section is ever empty.
DeckSection = Data.define(:name, :decks)

class DeckSection
  FAMILIES = { "BasicDeck" => "Basic", "MusicDeck" => "Music" }.freeze

  def self.for(user)
    language_sections(user) + family_sections(user)
  end

  def self.language_sections(user)
    lists = WordList.where(id: user.decks.select(:word_list_id))
    sections =
      lists.distinct.pluck(:language).map do |language|
        decks = user.decks.where(word_list: WordList.where(language:))
        new(name: WordList::LANGUAGES[language], decks:)
      end
    sections.sort_by(&:name)
  end

  def self.family_sections(user)
    FAMILIES.filter_map do |type, name|
      decks = user.decks.where(type:)
      new(name:, decks:) if decks.exists?
    end
  end

  # The first deck in page order still short of today's goal.
  def first_unmet = decks.goal_unmet_today.ordered.first
end
