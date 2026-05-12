# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicStudy do
  def answer_card(deck:, card:, answer: card.back)
    described_class.new(deck:).answer_card(card_id: card.id, answer:)
  end

  describe "#possible_answers" do
    it "returns an empty array regardless of deck contents" do
      deck = create(:music_deck)
      create(:music_card, deck:, back: "C4")
      create(:music_card, deck:, back: "E4")

      expect(described_class.new(deck:).possible_answers).to eq([])
    end
  end

  describe "#answer_card" do
    it "advances streak on a first-try correct answer" do
      deck = create(:music_deck)
      card = create(:music_card, deck:, back: "C4")

      answer_card(deck:, card:)

      expect(card.reload.correct_streak).to eq(1)
    end

    it "resets streak when answer does not match back" do
      deck = create(:music_deck)
      card = create(:music_card, deck:, back: "C4", correct_streak: 3)

      answer_card(deck:, card:, answer: "D4")

      expect(card.reload.correct_streak).to eq(0)
    end
  end
end
