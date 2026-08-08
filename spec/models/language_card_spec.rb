# frozen_string_literal: true

require "rails_helper"

# Exercised through ReadingCard - LanguageCard is never instantiated
# directly. Language cards keep nil content columns; everything reads
# through the data_set item.
RSpec.describe LanguageCard do
  it "reads the front from the item despite nil columns" do
    card = create(:reading_card, front: "明白")

    expect(card).to have_attributes(front: "明白")
      .and(satisfy("column is nil") { |c| c[:front].nil? })
  end

  it "rejoins a semicolon back from the item's glosses" do
    card = create(:reading_card, back: "understand;clear")

    expect(card.back).to eq("understand; clear")
  end

  it "reads the distractors from the item" do
    card = create(:reading_card, distractors: ["happy", "run"])

    expect(card.distractors).to contain_exactly("happy", "run")
  end

  it "reads reading and category from the item" do
    card = create(:reading_card, reading: "míngbai")

    expect(card).to have_attributes(reading: "míngbai", category: "General")
  end

  it "reads the example pair from the item" do
    card = create(:reading_card, example_front: "ef", example_back: "eb")

    expect(card).to have_attributes(example_front: "ef", example_back: "eb")
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
