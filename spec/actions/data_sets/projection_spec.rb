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
      deck = create(:reading_deck)
      described_class.build(deck, [row(front: "明白", back: "understand; clear")])

      expect(back_texts(deck)).to contain_exactly("understand", "clear")
    end

    it "creates a thin card linked to its Front item" do
      deck = create(:reading_deck)
      described_class.build(deck, [row(front: "明白", back: "x")])

      expect(deck.cards.sole.item.text).to eq("明白")
    end

    it "dedups a gloss shared across rows into one Back item" do
      deck = create(:reading_deck)
      rows = [row(front: "明白", back: "clear"), row(front: "清楚", back: "clear")]
      described_class.build(deck, rows)

      expect(back_texts(deck)).to contain_exactly("clear")
    end

    it "records distractors as referenced Back items" do
      deck = create(:reading_deck)
      rows = [row(front: "明白", back: "a", distractors: ["x", "y"])]
      described_class.build(deck, rows)

      front = deck.data_set.items.find_by(text: "明白")
      expect(front.distractors.pluck(:text)).to contain_exactly("x", "y")
    end

    it "skips pairings for a row whose back has no glosses" do
      deck = create(:reading_deck)
      described_class.build(deck, [row(front: "a", back: ";")])

      expect(back_texts(deck)).to be_empty
    end
  end

  describe ".replace" do
    def progress_counters(card)
      card.slice(:correct_streak, :correct_count, :view_count).values
    end

    it "resets progress when a card's back changes" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, front: "明白", back: "understand")
      card.update!(correct_streak: 3, correct_count: 5, view_count: 7)
      described_class.replace(deck, [row(front: "明白", back: "clear")])

      expect(progress_counters(card.reload)).to all(eq(0))
    end

    it "keeps progress when a card's back survives" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, front: "明白", back: "understand")
      card.update!(correct_streak: 3)
      described_class.replace(deck, [row(front: "明白", back: "understand")])

      expect(card.reload.correct_streak).to eq(3)
    end

    it "overwrites a preserved field when the CSV includes its column" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "两", back: "two", reading: "old")
      rows = [row(front: "两", back: "two", reading: "liǎng")]
      described_class.replace(deck, rows)

      expect(deck.cards.sole.reading).to eq("liǎng")
    end
  end

  describe ".add_distractor" do
    it "records a wrong guess as a referenced Back item" do
      card = create(:reading_card, front: "两", back: "two")
      described_class.add_distractor(card, "wrong")

      expect(card.item.distractors.pluck(:text)).to include("wrong")
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
      rows = [row(front: "明白", back: "understand;clear")]
      described_class.replace(fwd, rows)

      expect(reverse_prompts(rev)).to contain_exactly("understand", "clear")
    end

    it "removes a reverse card when the source loses a gloss" do
      fwd, rev = with_reverse([{ front: "明白", back: "understand;clear" }])
      described_class.replace(fwd, [row(front: "明白", back: "clear")])

      expect(reverse_prompts(rev)).to contain_exactly("clear")
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
      described_class.replace(fwd, [row(front: "懂", back: "understand")])

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
