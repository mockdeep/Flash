# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataSets::Projection do
  def row(front:, back:, **extra)
    { front:, back:, category: "", distractors: [], **extra }
  end

  def back_texts(deck)
    deck.reload.data_set.items.where(side: "Back").pluck(:text)
  end

  def front_texts(deck)
    deck.reload.data_set.items.where(side: "Front").pluck(:text)
  end

  describe ".build" do
    it "names the data_set after the deck" do
      deck = create(:deck, name: "HSK 1")
      described_class.build(deck, [row(front: "a", back: "b")])

      expect(deck.reload.data_set.name).to eq("HSK 1")
    end

    it "splits a semicolon back into multiple Back items" do
      deck = create(:deck)
      described_class.build(deck, [row(front: "明白", back: "understand; clear")])

      expect(back_texts(deck)).to contain_exactly("understand", "clear")
    end

    it "creates a thin card linked to its Front item" do
      deck = create(:deck)
      described_class.build(deck, [row(front: "明白", back: "x")])

      expect(deck.cards.sole.item.text).to eq("明白")
    end

    it "dedups a gloss shared across rows into one Back item" do
      deck = create(:deck)
      rows = [row(front: "明白", back: "clear"), row(front: "清楚", back: "clear")]
      described_class.build(deck, rows)

      expect(back_texts(deck)).to contain_exactly("clear")
    end

    it "records distractors as referenced Back items" do
      deck = create(:deck)
      rows = [row(front: "明白", back: "a", distractors: ["x", "y"])]
      described_class.build(deck, rows)

      front = deck.data_set.items.find_by(text: "明白")
      expect(front.distractors.pluck(:text)).to contain_exactly("x", "y")
    end

    it "skips pairings for a row whose back has no glosses" do
      deck = create(:deck)
      described_class.build(deck, [row(front: "a", back: ";")])

      expect(back_texts(deck)).to be_empty
    end
  end

  describe ".project" do
    it "reconciles a changed back, removing the orphaned Back item" do
      card = create(:card, front: "明白", back: "understand")
      described_class.project(card, row(front: "明白", back: "clear"))

      expect(back_texts(card.deck)).to contain_exactly("clear")
    end

    it "keeps a Back item still shared by another card" do
      create(:card, front: "清楚", back: "clear")
      card = create(:card, front: "明白", back: "clear")
      described_class.project(card, row(front: "明白", back: "bright"))

      expect(back_texts(card.deck)).to include("clear")
    end

    it "discards the old Front item when the front changes" do
      card = create(:card, front: "明白", back: "understand")
      described_class.project(card, row(front: "懂", back: "understand"))

      expect(front_texts(card.deck)).to contain_exactly("懂")
    end
  end

  describe ".add_distractor" do
    it "records a wrong guess as a referenced Back item" do
      card = create(:card, front: "a", back: "b")
      described_class.add_distractor(card, "wrong")

      expect(card.item.distractors.pluck(:text)).to include("wrong")
    end
  end

  describe ".remove_card" do
    it "removes the card's Front item and orphaned Back items" do
      card = create(:card, front: "a", back: "b")
      described_class.remove_card(card)
      card.destroy!

      expect(card.deck.reload.data_set.items).to be_empty
    end

    it "keeps Back items still used by another card" do
      create(:card, front: "x", back: "shared")
      card = create(:card, front: "y", back: "shared")
      described_class.remove_card(card)
      card.destroy!

      expect(back_texts(card.deck)).to contain_exactly("shared")
    end

    it "keeps a Back item still referenced as a distractor" do
      create(:card, front: "a", back: "z", distractors: ["x"])
      card = create(:card, front: "b", back: "x")
      described_class.remove_card(card)
      card.destroy!

      expect(back_texts(card.deck)).to include("x")
    end

    it "does nothing for a card with no item" do
      card = build(:card)

      expect { described_class.remove_card(card) }.not_to change(Item, :count)
    end
  end
end
