# frozen_string_literal: true

require "rails_helper"

RSpec.describe LanguageDeck do
  describe ".model_name" do
    it "returns the Deck model name for routing" do
      expect(described_class.model_name.route_key).to eq("decks")
    end
  end

  describe "#name" do
    it "reads through the word_list" do
      deck = create(:reading_deck, name: "HSK 1")

      expect(deck.name).to eq("HSK 1")
    end

    it "leaves the deck's own name column empty" do
      deck = create(:reading_deck, name: "HSK 1")

      expect(deck[:name]).to be_nil
    end
  end

  describe "#generates_distractors?" do
    it "is true whatever the pool column says" do
      deck = create(:reading_deck, distractor_pool: "preset")

      expect(deck.generates_distractors?).to be(true)
    end
  end

  describe "#backs" do
    it "narrows to the words the list files under a category" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, back: "tree", category: "Nature")
      create(:reading_card, deck:, back: "hand", category: "Body")

      expect(deck.backs(category: "Nature")).to eq(["tree"])
    end
  end

  describe "#reading_pairs" do
    it "reads sibling (headword, reading) pairs from the entries" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "两", reading: "liǎng")
      excluded = create(:reading_card, deck:, front: "三", reading: "sān")

      expect(deck.reading_pairs(except: excluded))
        .to contain_exactly(["两", "liǎng"])
    end
  end

  describe "#readings?" do
    it "is true when an entry holds a reading" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, reading: "liǎng")

      expect(deck.readings?).to be(true)
    end

    it "is false when every entry's reading is blank" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, reading: nil)
      create(:reading_card, deck:, reading: "")

      expect(deck.readings?).to be(false)
    end
  end
end
