# frozen_string_literal: true

RSpec.describe Study do
  describe "#pick_next_card" do
    it "returns a card when not-done cards exist" do
      deck = create(:deck)
      create(:card, deck:)

      study = described_class.new(deck:)

      expect(study.next_card).to be_a(Card)
    end

    it "limits cards to threshold" do
      deck = create(:deck)
      create_list(:card, 10, deck:)

      study = described_class.new(deck:, active_card_threshold: 5)

      expect(deck.cards.not_done.ordered.limit(5)).to include(study.next_card)
    end

    it "returns nil when no cards available" do
      deck = create(:deck)

      study = described_class.new(deck:)

      expect(study.next_card).to be_nil
    end

    it "does not return done cards as next card" do
      deck = create(:deck)
      create(:card, :done, deck:)

      study = described_class.new(deck:)

      expect(study.next_card).to be_nil
    end

    it "does not return cards beyond the threshold" do
      deck = create(:deck)
      create_list(:card, 10, deck:)

      study = described_class.new(deck:, active_card_threshold: 5)

      over_threshold = deck.cards.not_done.ordered.offset(5)
      expect(over_threshold).not_to include(study.next_card)
    end
  end

  describe "#complete?" do
    it "returns true when there is no next card" do
      deck = create(:deck)

      study = described_class.new(deck:)

      expect(study.complete?).to be(true)
    end

    it "returns false when a next card exists" do
      deck = create(:deck)
      create(:card, deck:)

      study = described_class.new(deck:)

      expect(study.complete?).to be(false)
    end
  end

  describe "#possible_answers" do
    it "returns empty array when no next card" do
      deck = create(:deck)
      study = described_class.new(deck:)

      expect(study.possible_answers).to eq([])
    end

    it "includes the correct answer" do
      deck = create(:deck)
      create(:card, deck:, back: "Paris")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Paris")
    end

    it "includes first wrong answer from card history" do
      deck = create(:deck)
      create(:card, deck:, wrong_answers: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    it "includes second wrong answer from card history" do
      deck = create(:deck)
      create(:card, deck:, wrong_answers: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Berlin")
    end

    it "includes cards from same category" do
      deck = create(:deck)
      create(:card, deck:, back: "Paris", category: "Geography")
      create(:card, deck:, back: "London", category: "Geography")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    context "when wrong answer matches a same-category card" do
      let(:deck) { create(:deck) }
      let(:attrs) { { deck:, category: "Geo" } }

      before do
        create(:card, wrong_answers: ["B"], **attrs)
        create(:card, back: "B", **attrs)
      end

      it "does not duplicate the answer" do
        answers = described_class.new(deck:).possible_answers

        expect(answers.tally.values).to all(eq(1))
      end
    end

    it "uses only the first 4 wrong answers from history" do
      deck = create(:deck)
      create(:card, deck:, wrong_answers: ["A", "B", "C", "D", "E"])

      study = described_class.new(deck:)

      expect(study.possible_answers).not_to include("E")
    end

    it "includes cards from other categories when needed" do
      deck = create(:deck)
      create(:card, deck:, back: "Paris", category: "Geography")
      create(:card, deck:, back: "Four", category: "Math")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Four")
    end
  end

  describe "#answer_card" do
    context "when answer is correct" do
      it "increments view count" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", view_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.view_count).to eq(1)
      end

      it "increments correct count" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.correct_count).to eq(1)
      end

      it "increments correct streak" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.correct_streak).to eq(1)
      end

      it "marks card as done when streak reaches threshold" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.done?).to be(true)
      end

      it "keeps card not done when streak below threshold" do
        stub_const("Card::DONE_THRESHOLD", 5)
        card = create(:card, back: "Paris", correct_streak: 0)
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.done?).to be(false)
      end

      it "returns card_completed true when streak meets threshold" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card_completed?).to be(true)
      end

      it "returns card_completed false when streak below threshold" do
        stub_const("Card::DONE_THRESHOLD", 5)
        card = create(:card, back: "Paris", correct_streak: 0)
        study = described_class.new(deck: card.deck)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card_completed?).to be(false)
      end

      it "returns result with correct true" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.correct?).to be(true)
      end

      it "returns result with correct answer" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.correct_answer).to eq("Paris")
      end

      it "returns result with question" do
        deck = create(:deck)
        card = create(:card, deck:, front: "Capital?", back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.question).to eq("Capital?")
      end

      it "returns result with the answered card" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card).to eq(card)
      end
    end

    context "when answer is incorrect" do
      it "increments view count" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", view_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.view_count).to eq(1)
      end

      it "resets correct streak" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris", correct_streak: 5)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.correct_streak).to eq(0)
      end

      it "adds wrong answer to card" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.wrong_answers).to eq(["London"])
      end

      it "prepends wrong answer to existing list" do
        card = create(:card, back: "Paris", wrong_answers: ["Berlin"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.wrong_answers).to eq(["London", "Berlin"])
      end

      it "removes duplicate wrong answers" do
        card = create(:card, back: "Paris", wrong_answers: ["London"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.wrong_answers).to eq(["London"])
      end

      it "returns result with card_completed false" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.card_completed?).to be(false)
      end

      it "returns result with correct false" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.correct?).to be(false)
      end

      it "returns result with correct answer" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.correct_answer).to eq("Paris")
      end

      it "returns result with question" do
        deck = create(:deck)
        card = create(:card, deck:, front: "Capital?", back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.question).to eq("Capital?")
      end

      it "returns result with the answered card" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.card).to eq(card)
      end
    end
  end
end
