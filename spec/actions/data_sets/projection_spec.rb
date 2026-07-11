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
      card = create(:basic_card, front: "明白", back: "understand")
      described_class.project(card, row(front: "明白", back: "clear"))

      expect(back_texts(card.deck)).to contain_exactly("clear")
    end

    it "keeps a Back item still shared by another card" do
      create(:basic_card, front: "清楚", back: "clear")
      card = create(:basic_card, front: "明白", back: "clear")
      described_class.project(card, row(front: "明白", back: "bright"))

      expect(back_texts(card.deck)).to include("clear")
    end

    it "discards the old Front item when the front changes" do
      card = create(:basic_card, front: "明白", back: "understand")
      described_class.project(card, row(front: "懂", back: "understand"))

      expect(front_texts(card.deck)).to contain_exactly("懂")
    end
  end

  describe ".add_distractor" do
    it "records a wrong guess as a referenced Back item" do
      card = create(:basic_card, front: "a", back: "b")
      described_class.add_distractor(card, "wrong")

      expect(card.item.distractors.pluck(:text)).to include("wrong")
    end
  end

  describe ".remove_card" do
    it "removes the card's Front item and orphaned Back items" do
      card = create(:basic_card, front: "a", back: "b")
      described_class.remove_card(card)
      card.destroy!

      expect(card.deck.reload.data_set.items).to be_empty
    end

    it "keeps Back items still used by another card" do
      create(:basic_card, front: "x", back: "shared")
      card = create(:basic_card, front: "y", back: "shared")
      described_class.remove_card(card)
      card.destroy!

      expect(back_texts(card.deck)).to contain_exactly("shared")
    end

    it "keeps a Back item still referenced as a distractor" do
      create(:basic_card, front: "a", back: "z", distractors: ["x"])
      card = create(:basic_card, front: "b", back: "x")
      described_class.remove_card(card)
      card.destroy!

      expect(back_texts(card.deck)).to include("x")
    end
  end

  describe "reverse-deck sync" do
    def with_reverse(forward_cards)
      fwd = create(:reading_deck)
      forward_cards.each { |attrs| create(:reading_card, deck: fwd, **attrs) }
      [fwd, Decks::CreateReverse.call(source: fwd).record]
    end

    def reverse_prompts(rev)
      rev.reload.cards.map(&:front)
    end

    it "creates one reverse card per paired back item" do
      _fwd, rev = with_reverse([{ front: "明白", back: "understand;clear" }])

      expect(reverse_prompts(rev)).to contain_exactly("understand", "clear")
    end

    it "omits a distractor-only back item from the reverse deck" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      described_class.add_distractor(fwd.cards.sole, "decoy")

      expect(reverse_prompts(rev)).to contain_exactly("understand")
    end

    it "adds a reverse card when the source gains a gloss" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      content = row(front: "明白", back: "understand;clear")
      described_class.project(fwd.cards.sole, content)

      expect(reverse_prompts(rev)).to contain_exactly("understand", "clear")
    end

    it "removes a reverse card when the source loses a gloss" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand;clear" }])
      described_class.project(fwd.cards.sole, row(front: "明白", back: "clear"))

      expect(reverse_prompts(rev)).to contain_exactly("clear")
    end

    it "destroys reverse cards when the source card is removed" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      described_class.remove_card(fwd.cards.sole)

      expect(reverse_prompts(rev)).to be_empty
    end

    it "reconciles reverse cards after a source replace" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      described_class.replace(fwd, [row(front: "你好", back: "hello")])

      expect(reverse_prompts(rev)).to contain_exactly("hello")
    end

    it "preserves reverse progress across a source replace" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      rev.cards.sole.update!(correct_streak: 3)
      described_class.replace(fwd, [row(front: "明白", back: "understand")])

      expect(rev.cards.sole.correct_streak).to eq(3)
    end

    it "resets reverse progress when the answer changes" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      rev.cards.sole.update!(correct_streak: 3)
      renamed = row(front: "懂", back: "understand")
      described_class.project(fwd.cards.sole, renamed)

      expect(rev.cards.sole.correct_streak).to eq(0)
    end

    it "records a reverse miss as a Front-side decoy" do
      _fwd, rev = with_reverse([{ front: "明白", back: "understand" }])
      card = rev.cards.sole
      described_class.add_distractor(card, "知道")

      expect(card.distractors).to contain_exactly("知道")
    end
  end
end
