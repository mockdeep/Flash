# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card do
  it { is_expected.to belong_to(:deck) }
  it { is_expected.to validate_inclusion_of(:status).in_array(Card::STATUSES) }
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

  describe ".active" do
    it "returns cards with active status" do
      deck = create(:deck)
      active_card = create(:card, :active, deck:)
      create(:card, :pending, deck:)

      expect(deck.cards.active).to eq([active_card])
    end
  end

  describe ".done" do
    it "returns cards with done status" do
      deck = create(:deck)
      done_card = create(:card, :done, deck:)
      create(:card, :active, deck:)

      expect(deck.cards.done).to eq([done_card])
    end
  end

  describe ".pending" do
    it "returns cards with pending status" do
      deck = create(:deck)
      pending_card = create(:card, :pending, deck:)
      create(:card, :active, deck:)

      expect(deck.cards.pending).to eq([pending_card])
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
end
