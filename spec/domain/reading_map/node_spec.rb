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
      expect(node(decks: [deck], unmet: true)).not_to be_met
    end

    it "is false when every deck has no goal" do
      expect(node(decks: [deck(goal_mode: "none")])).not_to be_met
    end

    it "is false with no deck" do
      expect(node).not_to be_met
    end
  end

  describe "#last_studied" do
    it "is when its latest deck was studied" do
      times = [2, 3].map { Time.zone.local(2026, 1, it) }
      decks = times.map { deck(last_studied_at: it) }

      expect(node(decks:).last_studied).to eq(times.last)
    end

    it "is long ago for decks never studied" do
      expect(node(decks: [deck]).last_studied).to eq(described_class::NEVER)
    end
  end
end
