# frozen_string_literal: true

require "rails_helper"

RSpec.describe BasicDeck do
  it "builds BasicCards" do
    expect(described_class.new.card_type).to eq("BasicCard")
  end

  it "is labeled Basic on the decks index" do
    expect(described_class.new.type_label).to eq("Basic")
  end

  it "has flat cards" do
    expect(described_class.new.flat_cards?).to be(true)
  end

  describe ".model_name" do
    it "returns the Deck model name for routing" do
      expect(described_class.model_name.route_key).to eq("decks")
    end
  end
end
