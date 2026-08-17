# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::Projection do
  describe ".build_cards" do
    def source_deck(cards)
      deck = create(:reading_deck)
      cards.each { |attrs| create(:reading_card, deck:, **attrs) }
      deck
    end

    def deck_over(word_list)
      create(:reading_deck, word_list:, user: create(:user))
    end

    def two_word_deck
      source_deck(
        [{ front: "明白", back: "understand" }, { front: "你好", back: "hi" }],
      )
    end

    it "creates one card per paired front item" do
      copy = deck_over(two_word_deck.word_list)

      described_class.build_cards(copy)

      expect(copy.cards.map(&:front)).to contain_exactly("明白", "你好")
    end

    it "omits an unpaired decoy item" do
      source = source_deck([{ front: "明白", back: "understand" }])
      described_class.add_distractor(source.cards.sole, "decoy")
      copy = deck_over(source.word_list)

      described_class.build_cards(copy)

      expect(copy.cards.map(&:front)).to contain_exactly("明白")
    end

    it "stops at the given limit" do
      copy = deck_over(two_word_deck.word_list)

      described_class.build_cards(copy, limit: 1)

      expect(copy.cards.count).to eq(1)
    end
  end

  describe ".add_distractor" do
    it "records a wrong guess as a referenced Back item" do
      card = create(:reading_card, front: "两", back: "two")
      described_class.add_distractor(card, "wrong")

      expect(card.item.distractors.pluck(:text)).to include("wrong")
    end
  end
end
