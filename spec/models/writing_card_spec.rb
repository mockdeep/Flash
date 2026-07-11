# frozen_string_literal: true

require "rails_helper"

RSpec.describe WritingCard do
  describe ".model_name" do
    it "returns the Card model name for routing" do
      expect(described_class.model_name.route_key).to eq("cards")
    end
  end

  # Reverse a forward deck holding a single (single-gloss) card and return its
  # one reverse card.
  def reverse_card(**forward)
    deck = create(:reading_deck)
    create(:reading_card, deck:, **forward)
    Decks::CreateReverse.call(source: deck).record.cards.sole
  end

  it "prompts with the back item's text" do
    expect(reverse_card(front: "明白", back: "understand").front)
      .to eq("understand")
  end

  it "answers with the paired front text" do
    expect(reverse_card(front: "明白", back: "understand").back).to eq("明白")
  end

  it "joins multiple paired fronts as the answer" do
    deck = create(:reading_deck)
    create(:reading_card, deck:, front: "明白", back: "understand")
    create(:reading_card, deck:, front: "清楚", back: "understand")
    rev = Decks::CreateReverse.call(source: deck).record
    expect(rev.cards.sole.back).to eq("明白; 清楚")
  end

  it "reads the reading from the answer front item" do
    card = reverse_card(front: "明白", back: "understand", reading: "míngbai")
    expect(card.reading).to eq("míngbai")
  end

  it "reads the category from the answer front item" do
    card = reverse_card(front: "明白", back: "understand", category: "verbs")
    expect(card.category).to eq("verbs")
  end

  it "reads the example pair from the answer front item" do
    card = reverse_card(example_front: "ef", example_back: "eb")
    expect(card).to have_attributes(example_front: "ef", example_back: "eb")
  end
end
