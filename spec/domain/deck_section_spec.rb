# frozen_string_literal: true

RSpec.describe DeckSection do
  describe ".for" do
    def section_names = described_class.for(default_user.decks).map(&:name)

    it "names a language section after the language" do
      create(:reading_deck, language: "zh")

      expect(section_names).to eq(["Mandarin"])
    end

    it "sorts language sections by name" do
      create(:reading_deck, language: "zh")
      create(:reading_deck, language: "pt")

      expect(section_names).to eq(["Mandarin", "Portuguese"])
    end

    it "puts Basic and then Music after the languages" do
      create(:music_deck)
      create(:deck)
      create(:reading_deck)

      expect(section_names).to eq(["Mandarin", "Basic", "Music"])
    end

    it "leaves out a family the user has no decks in" do
      create(:deck)

      expect(section_names).to eq(["Basic"])
    end

    it "leaves out decks it isn't given" do
      create(:deck, user: create(:user))

      expect(section_names).to be_empty
    end

    it "holds a language's decks in its section" do
      deck = create(:reading_deck, language: "pt")
      create(:reading_deck, language: "zh")

      section = described_class.for(default_user.decks).last
      expect(section.decks).to eq([deck])
    end
  end

  describe "#card_count" do
    def section_of(decks) = described_class.new(name: "Mandarin", decks:)

    it "counts a source's section decks once" do
      word_list = create(:word_list)
      snippets = create_list(:snippet, 2, word_list:)
      snippets.each { |snippet| create(:reading_deck, word_list:, snippet:) }

      expect(section_of(Deck.all).card_count).to eq(1)
    end

    it "counts each flat deck" do
      create_list(:deck, 2)

      expect(section_of(Deck.all).card_count).to eq(2)
    end
  end

  describe "#first_unmet" do
    it "returns the first deck by name still under today's goal" do
      create(:deck, name: "Zebra")
      deck = create(:deck, name: "Alpha")

      section = described_class.for(default_user.decks).first
      expect(section.first_unmet).to eq(deck)
    end
  end
end
