# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decks::CreateReverse do
  def source_deck(cards: [{ front: "明白", back: "understand;clear" }])
    deck = create(:reading_deck)
    cards.each { |attrs| create(:card, deck:, **attrs) }
    deck
  end

  describe ".call" do
    it "creates a WritingDeck" do
      result = described_class.call(source: source_deck)

      expect(result.record).to be_a(WritingDeck)
    end

    it "shares the source data_set" do
      source = source_deck
      result = described_class.call(source:)

      expect(result.record.data_set).to eq(source.data_set)
    end

    it "names it after the source" do
      source = create(:reading_deck, name: "HSK 1")
      create(:card, deck: source)
      result = described_class.call(source:)

      expect(result.record.name).to eq("HSK 1 (reversed)")
    end

    it "defaults the distractor pool to category" do
      result = described_class.call(source: source_deck)

      expect(result.record.distractor_pool).to eq("category")
    end

    it "generates one card per paired back item" do
      result = described_class.call(source: source_deck)

      expect(result.record.cards.count).to eq(2)
    end

    it "anchors a generated card to its Back item" do
      result = described_class.call(source: source_deck)
      card = result.record.cards.first

      expect(card.front).to be_in(["understand", "clear"])
    end

    it "fails when a reverse deck already exists" do
      source = source_deck
      described_class.call(source:)
      result = described_class.call(source:)

      expect(result).not_to be_success
    end

    it "fails when the source is not reversible" do
      result = described_class.call(source: create(:music_deck))

      expect(result).not_to be_success
    end

    it "fails when the source is a basic deck" do
      result = described_class.call(source: create(:deck))

      expect(result).not_to be_success
    end
  end
end
