# frozen_string_literal: true

RSpec.describe ReadingMap::Node do
  def node(**)
    described_class.new(word_list: nil, ring: 1, angle: 90.0, heat: nil, **)
  end

  def deck(**) = build_stubbed(:reading_deck, **)

  describe "#started?" do
    it "is true with a deck" do
      expect(node(decks: [deck])).to be_started
    end

    it "is false with none" do
      expect(node).not_to be_started
    end
  end

  describe "#met?" do
    it "is true once no deck is short of its goal" do
      expect(node(decks: [deck])).to be_met
    end

    it "is false while a deck is short of its goal" do
      decks = [deck]

      expect(node(decks:, unmet_decks: decks)).not_to be_met
    end

    it "is false when every deck has no goal" do
      expect(node(decks: [deck(goal_mode: "none")])).not_to be_met
    end

    it "is false with no deck" do
      expect(node).not_to be_met
    end
  end

  describe "#continue_deck" do
    it "is the first deck short of today's goal" do
      decks = [deck, deck, deck]

      expect(node(decks:, unmet_decks: decks.last(2)).continue_deck)
        .to eq(decks.second)
    end

    it "is the deck last studied once every goal is met" do
      decks = [deck, deck(last_studied_at: 1.day.ago), deck]

      expect(node(decks:).continue_deck).to eq(decks.second)
    end

    it "is the first deck when none has been studied" do
      decks = [deck, deck]

      expect(node(decks:).continue_deck).to eq(decks.first)
    end
  end
end
