# frozen_string_literal: true

RSpec.describe Study do
  describe "#pick_next_card" do
    it "activates pending cards up to threshold" do
      deck = create(:deck)
      create(:card, :pending, deck:)

      study = described_class.new(deck:)

      expect(study.next_card.status).to eq("active")
    end

    it "limits activation to threshold minus active count" do
      deck = create(:deck)
      create_list(:card, 3, :active, deck:)
      create_list(:card, 5, :pending, deck:)

      described_class.new(deck:, active_card_threshold: 5)

      expect(deck.cards.active.count).to eq(5)
    end

    it "returns nil when no cards available" do
      deck = create(:deck)

      study = described_class.new(deck:)

      expect(study.next_card).to be_nil
    end
  end

  describe "#possible_answers" do
    it "includes the correct answer" do
      deck = create(:deck)
      create(:card, :active, deck:, back: "Paris")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Paris")
    end

    it "includes first wrong answer from card history" do
      deck = create(:deck)
      create(:card, :active, deck:, wrong_answers: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    it "includes second wrong answer from card history" do
      deck = create(:deck)
      create(:card, :active, deck:, wrong_answers: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Berlin")
    end

    it "includes cards from same category" do
      deck = create(:deck)
      create(:card, :active, deck:, back: "Paris", category: "Geography")
      create(:card, deck:, back: "London", category: "Geography")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    it "includes cards from other categories when needed" do
      deck = create(:deck)
      create(:card, :active, deck:, back: "Paris", category: "Geography")
      create(:card, deck:, back: "Four", category: "Math")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Four")
    end
  end

  describe "#answer_card" do
    context "when answer is correct" do
      it "increments view count" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris", view_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.view_count).to eq(1)
      end

      it "increments correct count" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris", correct_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.correct_count).to eq(1)
      end

      it "increments correct streak" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.correct_streak).to eq(1)
      end

      it "marks card as done when streak reaches threshold" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.status).to eq("done")
      end

      it "keeps card active when streak below threshold" do
        stub_const("Study::CARD_DONE_THRESHOLD", 5)
        card = create(:card, :active, back: "Paris", correct_streak: 0)
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.status).to eq("active")
      end

      it "returns result with correct true" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.correct?).to be(true)
      end

      it "returns result with correct answer" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.correct_answer).to eq("Paris")
      end

      it "returns result with question" do
        deck = create(:deck)
        card = create(:card, :active, deck:, front: "Capital?", back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.question).to eq("Capital?")
      end
    end

    context "when answer is incorrect" do
      it "increments view count" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris", view_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.view_count).to eq(1)
      end

      it "resets correct streak" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris", correct_streak: 5)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.correct_streak).to eq(0)
      end

      it "adds wrong answer to card" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris")
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.wrong_answers).to eq(["London"])
      end

      it "prepends wrong answer to existing list" do
        card = create(:card, :active, back: "Paris", wrong_answers: ["Berlin"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.wrong_answers).to eq(["London", "Berlin"])
      end

      it "removes duplicate wrong answers" do
        card = create(:card, :active, back: "Paris", wrong_answers: ["London"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.wrong_answers).to eq(["London"])
      end

      it "returns result with correct false" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.correct?).to be(false)
      end

      it "returns result with correct answer" do
        deck = create(:deck)
        card = create(:card, :active, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.correct_answer).to eq("Paris")
      end

      it "returns result with question" do
        deck = create(:deck)
        card = create(:card, :active, deck:, front: "Capital?", back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.question).to eq("Capital?")
      end
    end
  end
end
