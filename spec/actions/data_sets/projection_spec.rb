# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataSets::Projection do
  def deck_with(backs)
    deck = create(:deck)
    backs.each_with_index do |back, index|
      create(:card, deck:, front: "f#{index}", back:)
    end
    described_class.rebuild(deck)
    deck
  end

  def annotated_card(deck)
    create(
      :card,
      deck:,
      front: "明白",
      back: "understand",
      category: "Verbs",
      reading: "míngbai",
      example_front: "我明白",
      example_back: "I understand",
    )
  end

  def deck_with_decoy_glossed_elsewhere
    deck = create(:deck)
    create(:card, deck:, front: "a", back: "z", distractors: ["x"])
    create(:card, deck:, front: "b", back: "x")
    described_class.rebuild(deck)
    deck
  end

  def back_texts(deck)
    deck.reload.data_set.items.where(side: "Back").pluck(:text)
  end

  def front_texts(deck)
    deck.reload.data_set.items.where(side: "Front").pluck(:text)
  end

  describe ".rebuild" do
    it "names the data_set after the deck" do
      deck = create(:deck, name: "HSK 1")
      create(:card, deck:)
      described_class.rebuild(deck)

      expect(deck.reload.data_set.name).to eq("HSK 1")
    end

    it "carries a card's annotations onto its Front item" do
      deck = create(:deck)
      annotated_card(deck)
      described_class.rebuild(deck)

      expect_projection_matches(deck)
    end

    it "splits a semicolon back into multiple Back items" do
      deck = deck_with(["understand; clear; obvious"])

      expect(back_texts(deck))
        .to contain_exactly("understand", "clear", "obvious")
    end

    it "links each card to its Front item" do
      deck = deck_with(["understand"])

      expect(deck.cards.first.reload.item.text).to eq("f0")
    end

    it "dedups a gloss shared across cards into one Back item" do
      deck = deck_with(["clear", "clear"])

      expect(back_texts(deck)).to contain_exactly("clear")
    end

    it "projects distractors as referenced Back items" do
      deck = create(:deck)
      create(:card, deck:, front: "f", back: "a", distractors: ["x", "y"])
      described_class.rebuild(deck)

      expect_projection_matches(deck)
    end

    it "skips pairings for a card whose back has no glosses" do
      deck = create(:deck)
      create(:card, deck:, back: ";")
      described_class.rebuild(deck)

      expect(deck.data_set.items.where(side: "Back")).to be_empty
    end

    it "drops content no longer present on a later rebuild" do
      deck = deck_with(["understand"])
      deck.cards.first.update!(back: "clear")
      described_class.rebuild(deck)

      expect(back_texts(deck)).to contain_exactly("clear")
    end
  end

  describe ".project_card" do
    it "removes a Back item orphaned by a changed back" do
      deck = deck_with(["understand"])
      deck.cards.first.update!(back: "clear")
      described_class.project_card(deck.cards.first)

      expect(back_texts(deck)).to contain_exactly("clear")
    end

    it "keeps a Back item still shared by another card" do
      deck = deck_with(["clear", "clear"])
      card = deck.cards.find_by(front: "f1")
      card.update!(back: "bright")
      described_class.project_card(card)

      expect(back_texts(deck)).to include("clear")
    end

    it "discards the old Front item when the front changes" do
      deck = deck_with(["understand"])
      card = deck.cards.first
      card.update!(front: "懂")
      described_class.project_card(card)

      expect(front_texts(deck)).to contain_exactly("懂")
    end
  end

  describe ".remove_card" do
    it "removes the card's Front item and orphaned Back items" do
      deck = deck_with(["understand"])
      described_class.remove_card(deck.cards.first)
      deck.cards.first.destroy!

      expect(deck.reload.data_set.items).to be_empty
    end

    it "keeps Back items still used by another card" do
      deck = deck_with(["clear", "clear"])
      card = deck.cards.find_by(front: "f1")
      described_class.remove_card(card)
      card.destroy!

      expect(back_texts(deck)).to contain_exactly("clear")
    end

    it "keeps a Back item still referenced as a distractor" do
      deck = deck_with_decoy_glossed_elsewhere
      card = deck.cards.find_by(front: "b")
      described_class.remove_card(card)
      card.destroy!

      expect(back_texts(deck)).to include("x")
    end

    it "does nothing for a card with no item" do
      card = build(:card)

      expect { described_class.remove_card(card) }.not_to change(Item, :count)
    end
  end
end
