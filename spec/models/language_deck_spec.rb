# frozen_string_literal: true

require "rails_helper"

RSpec.describe LanguageDeck do
  describe ".model_name" do
    it "returns the Deck model name for routing" do
      expect(described_class.model_name.route_key).to eq("decks")
    end
  end

  describe "#cards_in_category" do
    it "finds cards through the item layer" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, category: "Nature")
      create(:reading_card, deck:, category: "Body")

      expect(deck.cards_in_category("Nature")).to contain_exactly(card)
    end
  end

  describe "#reading_pairs" do
    it "reads sibling (front, reading) pairs through the item layer" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "两", reading: "liǎng")
      excluded = create(:reading_card, deck:, front: "三", reading: "sān")

      expect(deck.reading_pairs(except: excluded))
        .to contain_exactly(["两", "liǎng"])
    end
  end
end
