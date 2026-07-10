# frozen_string_literal: true

RSpec.describe Demo::CreateGuestUser do
  describe ".call" do
    def demo_deck_with_cards
      deck = create(:deck, visibility: "public")
      create(:card, deck:, front: "Q1", back: "A1")
      create(:card, deck:, front: "Q2", back: "A2")
      deck
    end

    it "creates a persisted guest user" do
      deck = demo_deck_with_cards
      result = described_class.call(deck:, time_zone: "UTC")

      expect(result.user).to be_persisted
    end

    it "assigns the guest role" do
      deck = demo_deck_with_cards
      result = described_class.call(deck:, time_zone: "UTC")

      expect(result.user.role).to eq("guest")
    end

    it "assigns the given time zone" do
      deck = demo_deck_with_cards
      result = described_class.call(deck:, time_zone: "America/New_York")

      expect(result.user.time_zone).to eq("America/New_York")
    end

    it "copies the deck to the guest user" do
      deck = demo_deck_with_cards
      result = described_class.call(deck:, time_zone: "UTC")

      expect(result.deck.user).to eq(result.user)
    end

    it "preserves the deck name" do
      deck = demo_deck_with_cards
      result = described_class.call(deck:, time_zone: "UTC")

      expect(result.deck.name).to eq(deck.name)
    end

    it "copies cards from the source deck" do
      deck = demo_deck_with_cards
      result = described_class.call(deck:, time_zone: "UTC")

      expect(result.deck.cards.count).to eq(2)
    end

    it "caps the copied cards at CARD_LIMIT" do
      stub_const("Demo::CreateGuestUser::CARD_LIMIT", 2)
      deck = demo_deck_with_cards
      create(:card, deck:, front: "Q3", back: "A3")

      result = described_class.call(deck:, time_zone: "UTC")

      expect(result.deck.cards.count).to eq(2)
    end
  end
end
