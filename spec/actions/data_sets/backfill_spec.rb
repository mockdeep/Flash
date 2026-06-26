# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataSets::Backfill do
  describe ".call" do
    it "builds a data_set for an existing text deck" do
      deck = create(:deck)
      create(:card, deck:, back: "understand;clear")
      described_class.call

      expect_projection_matches(deck)
    end

    it "returns the number of text decks processed" do
      create(:card)

      expect(described_class.call).to eq(1)
    end

    it "leaves music decks untouched" do
      deck = create(:music_deck)
      create(:music_card, deck:)
      described_class.call

      expect(deck.reload.data_set).to be_nil
    end

    it "is idempotent across repeated runs" do
      deck = create(:deck)
      create(:card, deck:, back: "x;y")
      2.times { described_class.call }

      expect_projection_matches(deck)
    end

    it "repairs a partially projected data_set" do
      deck = create(:deck)
      cards = create_list(:card, 2, deck:)
      DataSets::Projection.project_card(cards.first)
      described_class.call

      expect_projection_matches(deck)
    end
  end
end
