# frozen_string_literal: true

RSpec.describe Demo::CreateGuestUser do
  describe ".call" do
    let(:owner) { create(:user) }
    let(:demo_deck) { create(:deck, user: owner, visibility: "public") }

    before do
      create(:card, deck: demo_deck, front: "Q1", back: "A1")
      create(:card, deck: demo_deck, front: "Q2", back: "A2")
    end

    it "creates a persisted guest user" do
      result = described_class.call(deck: demo_deck)

      expect(result.user).to be_persisted
    end

    it "assigns the guest role" do
      result = described_class.call(deck: demo_deck)

      expect(result.user.role).to eq("guest")
    end

    it "copies the deck to the guest user" do
      result = described_class.call(deck: demo_deck)

      expect(result.deck.user).to eq(result.user)
    end

    it "preserves the deck name" do
      result = described_class.call(deck: demo_deck)

      expect(result.deck.name).to eq(demo_deck.name)
    end

    it "copies cards from the source deck" do
      result = described_class.call(deck: demo_deck)

      expect(result.deck.cards.count).to eq(2)
    end

    it "caps the copied cards at CARD_LIMIT" do
      stub_const("Demo::CreateGuestUser::CARD_LIMIT", 2)
      create(:card, deck: demo_deck, front: "Q3", back: "A3")

      result = described_class.call(deck: demo_deck)

      expect(result.deck.cards.count).to eq(2)
    end
  end
end
