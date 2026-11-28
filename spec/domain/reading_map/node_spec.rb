# frozen_string_literal: true

RSpec.describe ReadingMap::Node do
  def node(**)
    described_class.new(word_list: nil, ring: 1, angle: 90.0, heat: nil, **)
  end

  def deck(**) = build_stubbed(:reading_deck, **)

  describe "#started?" do
    it "is true with a deck" do
      expect(node(deck:)).to be_started
    end

    it "is false with none" do
      expect(node).not_to be_started
    end
  end

  describe "#met?" do
    it "is true once its deck is no longer short of its goal" do
      expect(node(deck:)).to be_met
    end

    it "is false while its deck is short of its goal" do
      expect(node(deck:, unmet: true)).not_to be_met
    end

    it "is false when its deck has no goal" do
      expect(node(deck: deck(goal_mode: "none"))).not_to be_met
    end

    it "is false with no deck" do
      expect(node).not_to be_met
    end
  end
end
