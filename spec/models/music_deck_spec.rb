# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicDeck do
  describe "#music?" do
    it "returns true" do
      expect(described_class.new.music?).to be(true)
    end
  end

  it "is labeled Practice on the decks index" do
    expect(described_class.new.type_label).to eq("Practice")
  end

  it "has flat cards" do
    expect(described_class.new.flat_cards?).to be(true)
  end

  describe "#distractor_pool" do
    it "defaults to 'none'" do
      expect(described_class.new.distractor_pool).to eq("none")
    end

    it "respects an explicit value" do
      deck = described_class.new(distractor_pool: "category")

      expect(deck.distractor_pool).to eq("category")
    end
  end

  describe ".model_name" do
    it "returns the Deck model name for routing" do
      expect(described_class.model_name.route_key).to eq("decks")
    end
  end
end
