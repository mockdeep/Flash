# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card do
  it { is_expected.to belong_to(:deck) }
  it { is_expected.to belong_to(:item).optional }
  it { is_expected.to validate_presence_of(:correct_count) }
  it { is_expected.to validate_presence_of(:correct_streak) }
  it { is_expected.to validate_presence_of(:deck_id) }
  it { is_expected.to validate_presence_of(:view_count) }

  describe ".done" do
    it "returns cards with correct_streak at or above the given level" do
      deck = create(:deck)
      done_card = create(:basic_card, :done, deck:)
      create(:basic_card, deck:)

      expect(deck.cards.done(1)).to eq([done_card])
    end

    it "respects a custom level argument" do
      deck = create(:deck, level: 3)
      done_card = create(:basic_card, deck:, correct_streak: 3)
      create(:basic_card, deck:, correct_streak: 2)

      expect(deck.cards.done(3)).to eq([done_card])
    end
  end

  describe ".not_done" do
    it "returns cards with correct_streak below the given level" do
      deck = create(:deck)
      not_done_card = create(:basic_card, deck:)
      create(:basic_card, :done, deck:)

      expect(deck.cards.not_done(1)).to eq([not_done_card])
    end

    it "respects a custom level argument" do
      deck = create(:deck, level: 3)
      not_done_card = create(:basic_card, deck:, correct_streak: 2)
      create(:basic_card, deck:, correct_streak: 3)

      expect(deck.cards.not_done(3)).to eq([not_done_card])
    end
  end

  describe ".ordered" do
    it "returns cards ordered by id" do
      deck = create(:deck)
      card1 = create(:basic_card, deck:)
      card2 = create(:basic_card, deck:)

      expect(deck.cards.ordered).to eq([card1, card2])
    end
  end

  describe "#done?" do
    it "returns true when correct_streak meets deck level" do
      deck = create(:deck, level: 2)
      card = create(:basic_card, deck:, correct_streak: 2)

      expect(card.done?).to be(true)
    end

    it "returns false when correct_streak is below deck level" do
      deck = create(:deck, level: 2)
      card = create(:basic_card, deck:, correct_streak: 1)

      expect(card.done?).to be(false)
    end
  end

  describe "#suggestable_to_catalog?" do
    def build_catalog_copy(catalog_deck:, user:)
      catalog_card = create(:basic_card, deck: catalog_deck)
      copy_deck = create(:deck, user:)
      create(:basic_card, deck: copy_deck, source_card: catalog_card)
    end

    it "returns true when card has a public source deck owned by another" do
      catalog = create(:deck, user: create(:user), visibility: "public")
      card = build_catalog_copy(catalog_deck: catalog, user: create(:user))

      expect(card.suggestable_to_catalog?).to be(true)
    end

    it "returns false when the card has no source_card" do
      card = create(:basic_card)

      expect(card.suggestable_to_catalog?).to be(false)
    end

    it "returns false when the source deck is no longer public" do
      catalog = create(:deck, user: create(:user), visibility: "public")
      card = build_catalog_copy(catalog_deck: catalog, user: create(:user))
      catalog.update!(visibility: "private")

      expect(card.reload.suggestable_to_catalog?).to be(false)
    end

    it "returns false when the source deck is owned by the same user" do
      owner = create(:user)
      catalog = create(:deck, user: owner, visibility: "public")
      card = build_catalog_copy(catalog_deck: catalog, user: owner)

      expect(card.suggestable_to_catalog?).to be(false)
    end
  end

  describe "content from the card's own columns" do
    it "reads the front" do
      card = create(:basic_card, front: "明白")

      expect(card.front).to eq("明白")
    end

    it "reads a semicolon back rejoined from its glosses" do
      card = create(:basic_card, back: "understand;clear")

      expect(card.back).to eq("understand; clear")
    end

    it "reads the distractors from card_distractors" do
      card = create(:basic_card, distractors: ["happy", "run"])

      expect(card.distractors).to contain_exactly("happy", "run")
    end

    it "reads reading and category" do
      card = create(:basic_card, reading: "míngbai")

      expect(card).to have_attributes(reading: "míngbai", category: "General")
    end

    it "reads the example pair" do
      card = create(:basic_card, example_front: "ef", example_back: "eb")

      expect(card).to have_attributes(example_front: "ef", example_back: "eb")
    end

    it "has no item to read through" do
      card = create(:basic_card, front: "Q")

      expect(card).to have_attributes(item: nil, front: "Q")
    end
  end

  describe "#record_miss!" do
    it "records the chosen answer as a card distractor" do
      card = create(:basic_card)
      card.record_miss!("wrong")

      expect(card.card_distractors.pluck(:text)).to contain_exactly("wrong")
    end

    it "does not write the item layer" do
      card = create(:basic_card)

      expect { card.record_miss!("wrong") }
        .not_to change(ItemDistractor, :count)
    end

    it "records no distractor without a chosen answer" do
      card = create(:basic_card)
      card.record_miss!

      expect(card.card_distractors).to be_empty
    end
  end
end
