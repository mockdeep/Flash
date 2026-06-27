# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicStudy do
  def make_deck(notes, ordered: true, level: 1)
    deck = create(:music_deck, ordered:, level:)
    notes.each_with_index do |note, i|
      create(:music_card, deck:, front: "front-#{i}-#{note}", back: note)
    end
    deck
  end

  def submit_window(study, answer:)
    study.answer_window(card_ids: study.next_window.map(&:id), answer:)
  end

  def window_backs(deck)
    described_class.new(deck:).pick_window.map(&:back)
  end

  def bump_others(deck, except)
    deck.cards.where.not(id: except.id).find_each do |card|
      card.update!(correct_streak: 5)
    end
  end

  describe "#possible_answers" do
    it "returns an empty array regardless of deck contents" do
      deck = make_deck(["C4", "E4"])

      expect(described_class.new(deck:).possible_answers).to eq([])
    end
  end

  describe "#pick_window" do
    it "returns an empty array for an empty deck" do
      deck = create(:music_deck)

      expect(described_class.new(deck:).pick_window).to eq([])
    end

    it "returns a single card at level 1" do
      deck = make_deck(["C4", "E4", "G4"], level: 1)

      expect(window_backs(deck)).to eq(["C4"])
    end

    it "returns the first N cards at level N for an ordered deck" do
      deck = make_deck(["C4", "E4", "G4", "C5"], level: 3)
      backs = window_backs(deck)

      expect(backs).to eq(["C4", "E4", "G4"])
    end

    it "advances the anchor as cards gain streak" do
      deck = make_deck(["C4", "E4", "G4", "C5"], level: 1)
      deck.cards.ordered.first.update!(correct_streak: 1)
      backs = window_backs(deck)

      expect(backs).to eq(["E4"])
    end

    it "clamps the window when the anchor is near the end of the melody" do
      deck = make_deck(["C4", "E4", "G4", "C5"], level: 3)
      deck.cards.ordered.first(3).each { |c| c.update!(correct_streak: 1) }
      backs = window_backs(deck)

      expect(backs).to eq(["E4", "G4", "C5"])
    end

    it "returns the whole deck when level equals melody length" do
      deck = make_deck(["C4", "E4", "G4"], level: 3)
      backs = window_backs(deck)

      expect(backs).to eq(["C4", "E4", "G4"])
    end

    it "clamps to deck size when level exceeds melody length" do
      deck = make_deck(["C4", "E4", "G4"], level: 5)

      expect(described_class.new(deck:).pick_window.size).to eq(3)
    end

    it "draws N cards for an unordered deck" do
      deck = make_deck(["C4", "E4", "G4", "A4"], ordered: false, level: 3)
      window = described_class.new(deck:).pick_window

      expect(window.size).to eq(3)
    end

    it "includes the anchor as the first card in an unordered window" do
      deck = make_deck(["C4", "E4", "G4", "A4"], ordered: false, level: 3)
      keep_lowest = deck.cards.find { |c| c.back == "G4" }
      bump_others(deck, keep_lowest)

      expect(window_backs(deck).first).to eq("G4")
    end
  end

  describe "#answer_window" do
    it "increments streak for every card in the window on a correct answer" do
      deck = make_deck(["C4", "E4", "G4"], level: 3)
      submit_window(described_class.new(deck:), answer: "C4,E4,G4")

      expect(deck.cards.ordered.pluck(:correct_streak)).to eq([1, 1, 1])
    end

    it "does not change streak on a wrong answer" do
      deck = make_deck(["C4", "E4", "G4"], level: 3)
      deck.cards.find_each { |c| c.update!(correct_streak: 2) }
      submit_window(described_class.new(deck:), answer: "wrong")

      expect(deck.cards.ordered.pluck(:correct_streak)).to eq([2, 2, 2])
    end

    it "increments view_count even on a wrong answer" do
      deck = make_deck(["C4", "E4", "G4"], level: 3)
      submit_window(described_class.new(deck:), answer: "wrong")

      expect(deck.cards.ordered.pluck(:view_count)).to eq([1, 1, 1])
    end

    it "advances the deck level when every card reaches the threshold" do
      deck = make_deck(["C4", "E4"], level: 1)
      deck.cards.find_each { |c| c.update!(correct_streak: 1) }
      submit_window(described_class.new(deck:), answer: "C4")

      expect(deck.reload.level).to eq(2)
    end

    it "returns a Result with the anchor as result.card" do
      deck = make_deck(["C4", "E4", "G4"], level: 3)
      study = described_class.new(deck:)
      result = submit_window(study, answer: "C4,E4,G4")

      expect(result.card.back).to eq("C4")
    end

    it "returns the joined window backs as correct_answer" do
      deck = make_deck(["C4", "E4", "G4"], level: 3)
      result = submit_window(described_class.new(deck:), answer: "C4,E4,G4")

      expect(result.correct_answer).to eq("C4,E4,G4")
    end

    it "reports card_completed when the anchor crosses the threshold" do
      deck = make_deck(["C4", "E4", "G4"], level: 1)
      result = submit_window(described_class.new(deck:), answer: "C4")

      expect(result.card_completed?).to be(true)
    end
  end

  describe "#record_answer" do
    def params_for(window, answer)
      ActionController::Parameters.new(
        answer: { card_ids: window.map { |c| c.id.to_s }, answer: },
      )
    end

    it "delegates to #answer_window via permitted params" do
      deck = make_deck(["C4", "E4"], level: 2)
      study = described_class.new(deck:)
      result = study.record_answer(params_for(study.next_window, "C4,E4"))

      expect(result.correct?).to be(true)
    end
  end
end
