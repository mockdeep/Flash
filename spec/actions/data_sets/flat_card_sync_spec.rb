# frozen_string_literal: true

require "rails_helper"

# The sync itself runs through the projection's write paths, so these specs
# drive it the way production does and assert on the raw card columns
# (card[:front] etc. - the readers still go through items until the switch).
RSpec.describe DataSets::FlatCardSync do
  def row(front:, back:, **extra)
    { front:, back:, category: "", distractors: [], **extra }
  end

  def full_content
    {
      front: "Q",
      back: "A",
      category: "C",
      reading: "kyū",
      example_front: "EF",
      example_back: "EB",
    }
  end

  describe "content stamping" do
    it "stamps a basic card's columns on build" do
      deck = create(:deck)
      DataSets::Projection.build(deck, [row(**full_content)])

      expect(deck.cards.sole.attributes.symbolize_keys).to include(full_content)
    end

    it "joins multi-gloss backs into the back column" do
      deck = create(:deck)
      DataSets::Projection.build(deck, [row(front: "Q", back: "a; b")])

      expect(deck.cards.sole[:back]).to eq("a; b")
    end

    it "stamps a music card's columns on build" do
      deck = create(:music_deck)
      DataSets::Projection.build(deck, [row(front: "Do", back: "C3")])

      expect(deck.cards.sole[:back]).to eq("C3")
    end

    it "restamps the card on a content edit" do
      card = create(:basic_card, front: "Q", back: "old")
      DataSets::Projection.project(card, row(front: "Q", back: "new"))

      expect(card.reload[:back]).to eq("new")
    end

    it "leaves language cards unstamped" do
      deck = create(:reading_deck)
      DataSets::Projection.build(deck, [row(front: "明白", back: "understand")])

      expect(deck.cards.sole[:front]).to be_nil
    end
  end

  describe "distractor mirroring" do
    it "mirrors uploaded distractors to card_distractors" do
      deck = create(:deck)
      rows = [row(front: "Q", back: "A", distractors: ["x", "y"])]
      DataSets::Projection.build(deck, rows)

      expect(deck.cards.sole.card_distractors.pluck(:text))
        .to contain_exactly("x", "y")
    end

    it "mirrors a recorded miss" do
      card = create(:basic_card)
      DataSets::Projection.add_distractor(card, "wrong")

      expect(card.card_distractors.pluck(:text)).to contain_exactly("wrong")
    end

    it "does not mirror a language deck's miss" do
      deck = create(:reading_deck)
      DataSets::Projection.build(deck, [row(front: "明白", back: "understand")])
      card = deck.cards.sole
      DataSets::Projection.add_distractor(card, "wrong")

      expect(card.card_distractors).to be_empty
    end

    it "removes mirrored rows the item layer no longer has" do
      card = create(:basic_card, front: "Q", back: "A", distractors: ["x"])
      DataSets::Projection.project(
        card, row(front: "Q", back: "A", distractors: ["y"])
      )

      expect(card.card_distractors.pluck(:text)).to contain_exactly("y")
    end
  end
end
