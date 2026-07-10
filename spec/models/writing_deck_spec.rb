# frozen_string_literal: true

require "rails_helper"

RSpec.describe WritingDeck do
  it "anchors the Back side" do
    expect(described_class.new.anchor_side).to eq("Back")
  end

  it "anchors on the paired_item pairing column" do
    expect(described_class.new.anchor_pairing_column).to eq(:paired_item_id)
  end

  it "builds ReverseTextCards" do
    expect(described_class.new.card_type).to eq("ReverseTextCard")
  end

  it "is not itself reversible" do
    expect(described_class.new.reversible?).to be(false)
  end

  describe "#cards_in_category" do
    def reverse_with_categories
      fwd = create(:reading_deck)
      create(:card, deck: fwd, front: "明白", back: "know", category: "v")
      create(:card, deck: fwd, front: "你好", back: "hi", category: "g")
      Decks::CreateReverse.call(source: fwd).record
    end

    it "returns cards whose answer front carries the category" do
      rev = reverse_with_categories
      expect(rev.cards_in_category("v").map(&:back)).to contain_exactly("明白")
    end
  end
end
