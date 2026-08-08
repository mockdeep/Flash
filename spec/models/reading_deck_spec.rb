# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingDeck do
  it "builds ReadingCards" do
    expect(described_class.new.card_type).to eq("ReadingCard")
  end

  it "is labeled Reading on the decks index" do
    expect(described_class.new.type_label).to eq("Reading")
  end

  it "sorts first among its set's decks" do
    expect(described_class.new.type_position).to eq(1)
  end

  it "does not have flat cards" do
    expect(described_class.new.flat_cards?).to be(false)
  end
end
