# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicCard do
  describe "back format validation" do
    it "accepts a single natural note" do
      card = build(:music_card, back: "E3")

      expect(card).to be_valid
    end

    it "accepts a single sharp note" do
      card = build(:music_card, back: "F#3")

      expect(card).to be_valid
    end

    it "rejects a comma-separated sequence" do
      card = build(:music_card, back: "C4,E4,G4")

      expect(card).not_to be_valid
    end

    it "rejects a bare letter without an octave" do
      card = build(:music_card, back: "E")

      expect(card).not_to be_valid
    end

    it "rejects an out-of-range letter" do
      card = build(:music_card, back: "H3")

      expect(card).not_to be_valid
    end

    it "rejects a flat (only sharps supported)" do
      card = build(:music_card, back: "Bb3")

      expect(card).not_to be_valid
    end

    it "rejects whitespace-separated notes" do
      card = build(:music_card, back: "C4 E4 G4")

      expect(card).not_to be_valid
    end
  end

  describe ".model_name" do
    it "returns the Card model name for routing" do
      expect(described_class.model_name.route_key).to eq("cards")
    end
  end
end
