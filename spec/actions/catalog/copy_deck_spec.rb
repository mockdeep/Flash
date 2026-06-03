# frozen_string_literal: true

RSpec.describe Catalog::CopyDeck do
  describe ".call" do
    def build_public_deck(name: "Public")
      owner = create(:user)
      create(:deck, user: owner, visibility: "public", name:)
    end

    it "returns success result" do
      source = build_public_deck
      create(:card, deck: source, front: "Q1", back: "A1")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.success?).to be(true)
    end

    it "creates a new deck for the user" do
      source = build_public_deck
      user = create(:user)

      expect { described_class.call(user:, deck: source) }
        .to change { user.decks.count }.by(1)
    end

    it "copies the deck name" do
      source = build_public_deck(name: "My Deck")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.name).to eq("My Deck")
    end

    it "copies two cards from the source deck" do
      source = build_public_deck
      create(:card, deck: source, front: "Q1", back: "A1")
      create(:card, deck: source, front: "Q2", back: "A2")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.count).to eq(2)
    end

    it "copies card front" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "Paris")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.front).to eq("Q")
    end

    it "copies card back" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "Paris")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.back).to eq("Paris")
    end

    it "copies card category" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "A", category: "Geo")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.category).to eq("Geo")
    end

    it "zeroes correct_count" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "A", correct_count: 5)
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.correct_count).to eq(0)
    end

    it "zeroes correct_streak" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "A", correct_streak: 3)
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.correct_streak).to eq(0)
    end

    it "zeroes view_count" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "A", view_count: 10)
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.view_count).to eq(0)
    end

    it "resets level to 1" do
      source = build_public_deck
      source.update!(level: 3)
      create(:card, deck: source, front: "Q", back: "A")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.level).to eq(1)
    end

    it "returns failure when user already has deck with that name" do
      source = build_public_deck(name: "Dup")
      user = create(:user)
      create(:deck, user:, name: "Dup")
      result = described_class.call(user:, deck: source)

      expect(result.success?).to be(false)
    end

    it "does not create cards when deck save fails" do
      source = build_public_deck(name: "Dup")
      create(:card, deck: source, front: "Q", back: "A")
      user = create(:user).tap { |u| create(:deck, user: u, name: "Dup") }

      expect { described_class.call(user:, deck: source) }
        .not_to change(Card, :count)
    end

    it "handles a deck with no cards" do
      source = build_public_deck
      result = described_class.call(user: create(:user), deck: source)

      expect(result.success?).to be(true)
    end

    it "creates zero cards for empty source deck" do
      source = build_public_deck
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.count).to eq(0)
    end

    it "copies distractor_pool from the source deck" do
      source = build_public_deck
      source.update!(distractor_pool: "preset")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.distractor_pool).to eq("preset")
    end

    it "copies card distractors when source pool is preset" do
      source = build_public_deck
      source.update!(distractor_pool: "preset")
      create(:card, deck: source, front: "Q", back: "A", distractors: ["W"])
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.distractors).to eq(["W"])
    end

    it "does not copy card distractors when source pool is category" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "A", distractors: ["W"])
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.distractors).to eq([])
    end

    it "caps copied cards when card_limit is set" do
      source = build_public_deck
      3.times { |i| create(:card, deck: source, front: "Q#{i}", back: "A#{i}") }
      user = create(:user)
      result = described_class.call(user:, deck: source, card_limit: 2)

      expect(result.record.cards.count).to eq(2)
    end

    it "copies all cards when card_limit exceeds card count" do
      source = build_public_deck
      create(:card, deck: source, front: "Q", back: "A")
      user = create(:user)
      result = described_class.call(user:, deck: source, card_limit: 10)

      expect(result.record.cards.count).to eq(1)
    end

    it "links each copied card back to its source card" do
      source = build_public_deck
      source_card = create(:card, deck: source, front: "Q", back: "A")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.source_card_id).to eq(source_card.id)
    end

    it "copies the card reading" do
      source = build_public_deck
      create(:card, deck: source, front: "两", back: "two", reading: "liǎng")
      result = described_class.call(user: create(:user), deck: source)

      expect(result.record.cards.first.reading).to eq("liǎng")
    end
  end
end
