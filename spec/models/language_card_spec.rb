# frozen_string_literal: true

require "rails_helper"

# Exercised through ReadingCard - LanguageCard is never instantiated
# directly. Language cards keep nil content columns; the front side reads
# through the item's entry, the back side through the list's senses.
RSpec.describe LanguageCard do
  it "requires an item" do
    card = ReadingCard.new(deck: build(:reading_deck))

    card.valid?

    expect(card.errors[:item]).to be_present
  end

  it "reads the front from the entry despite nil columns" do
    card = create(:reading_card, front: "明白")

    expect(card).to have_attributes(front: "明白")
      .and(satisfy("column is nil") { |c| c[:front].nil? })
  end

  it "shares one entry with a card for the same word in another list" do
    card = create(:reading_card, front: "明白", reading: "míngbai")
    other = create(:reading_card, front: "明白", reading: "míngbai")

    expect(card.entry).to eq(other.entry)
  end

  it "rejoins the back from the list's senses in membership order" do
    card = create(:reading_card, back: "understand;clear")

    expect(card.back).to eq("understand; clear")
  end

  it "shows only the senses its own list selected" do
    card = create(:reading_card, front: "花", back: "flower")
    create(:reading_card, front: "花", back: "to spend")

    expect(card.back).to eq("flower")
  end

  it "reads the distractors from the item" do
    card = create(:reading_card, distractors: ["happy", "run"])

    expect(card.distractors).to contain_exactly("happy", "run")
  end

  it "reads the reading from the entry and the category from the list" do
    card = create(:reading_card, reading: "míngbai")

    expect(card).to have_attributes(reading: "míngbai", category: "General")
  end

  it "reads the example pair from the senses" do
    card = create(:reading_card, example_front: "ef", example_back: "eb")

    expect(card).to have_attributes(example_front: "ef", example_back: "eb")
  end

  it "has no example when its senses hold none" do
    card = create(:reading_card)

    expect(card).to have_attributes(example_front: nil, example_back: nil)
  end

  describe "#homograph?" do
    it "is true when another card's entry shares the headword" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, front: "过", reading: "guò")
      create(:reading_card, deck:, front: "过", reading: "guo")

      expect(card.homograph?).to be(true)
    end

    it "is false when no other card's entry shares the headword" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, front: "过")
      create(:reading_card, deck:, front: "还")

      expect(card.homograph?).to be(false)
    end
  end

  describe "#record_miss!" do
    it "records the chosen answer as an item-side decoy" do
      card = create(:reading_card)
      card.record_miss!("wrong")

      expect(card.item.distractors.pluck(:text)).to include("wrong")
    end

    it "does not write card_distractors" do
      card = create(:reading_card)
      card.record_miss!("wrong")

      expect(card.card_distractors).to be_empty
    end
  end
end
