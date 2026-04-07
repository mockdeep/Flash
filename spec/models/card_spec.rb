# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card do
  it { is_expected.to belong_to(:deck) }
  it { is_expected.to validate_presence_of(:back) }
  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:correct_count) }
  it { is_expected.to validate_presence_of(:correct_streak) }
  it { is_expected.to validate_presence_of(:deck_id) }
  it { is_expected.to validate_presence_of(:front) }
  it { is_expected.to validate_presence_of(:view_count) }

  it do
    create(:card, front: "Sample Front")

    expect(described_class.new)
      .to validate_uniqueness_of(:front).scoped_to(:deck_id)
  end

  describe ".done" do
    it "returns cards with correct_streak at or above the given level" do
      deck = create(:deck)
      done_card = create(:card, :done, deck:)
      create(:card, deck:)

      expect(deck.cards.done(1)).to eq([done_card])
    end

    it "respects a custom level argument" do
      deck = create(:deck, level: 3)
      done_card = create(:card, deck:, correct_streak: 3)
      create(:card, deck:, correct_streak: 2)

      expect(deck.cards.done(3)).to eq([done_card])
    end
  end

  describe ".not_done" do
    it "returns cards with correct_streak below the given level" do
      deck = create(:deck)
      not_done_card = create(:card, deck:)
      create(:card, :done, deck:)

      expect(deck.cards.not_done(1)).to eq([not_done_card])
    end

    it "respects a custom level argument" do
      deck = create(:deck, level: 3)
      not_done_card = create(:card, deck:, correct_streak: 2)
      create(:card, deck:, correct_streak: 3)

      expect(deck.cards.not_done(3)).to eq([not_done_card])
    end
  end

  describe ".ordered" do
    it "returns cards ordered by id" do
      deck = create(:deck)
      card1 = create(:card, deck:)
      card2 = create(:card, deck:)

      expect(deck.cards.ordered).to eq([card1, card2])
    end
  end

  describe "#done?" do
    it "returns true when correct_streak meets deck level" do
      deck = create(:deck, level: 2)
      card = create(:card, deck:, correct_streak: 2)

      expect(card.done?).to be(true)
    end

    it "returns false when correct_streak is below deck level" do
      deck = create(:deck, level: 2)
      card = create(:card, deck:, correct_streak: 1)

      expect(card.done?).to be(false)
    end
  end
end
