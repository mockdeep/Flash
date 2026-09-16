# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingDeck do
  it "is labeled Reading on the decks index" do
    expect(described_class.new.type_label).to eq("Reading")
  end

  it "does not have flat cards" do
    expect(described_class.new.flat_cards?).to be(false)
  end

  it "scores the reading skill" do
    expect(described_class.new.skill).to eq("reading")
  end
end
