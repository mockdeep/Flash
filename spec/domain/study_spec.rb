# frozen_string_literal: true

RSpec.describe Study do
  def answer_card(deck:, card:, answer: card.back)
    described_class.new(deck:).answer_card(card_id: card.id, answer:)
  end

  describe ".for" do
    it "returns a Study for a text deck" do
      deck = create(:deck)

      expect(described_class.for(deck:)).to be_an_instance_of(described_class)
    end

    it "returns a MusicStudy for a music deck" do
      deck = create(:music_deck)

      expect(described_class.for(deck:)).to be_an_instance_of(MusicStudy)
    end
  end

  describe "#active_card_threshold" do
    it "returns the base threshold at level 1" do
      deck = create(:deck, level: 1)

      expect(described_class.new(deck:).active_card_threshold).to eq(20)
    end

    it "doubles with each level" do
      deck = create(:deck, level: 3)

      expect(described_class.new(deck:).active_card_threshold).to eq(80)
    end
  end

  describe "#pick_next_card" do
    it "returns a card when not-done cards exist" do
      deck = create(:deck)
      create(:card, deck:)

      study = described_class.new(deck:)

      expect(study.next_card).to be_a(Card)
    end

    it "limits cards to threshold" do
      stub_const("Study::ACTIVE_CARD_THRESHOLD", 5)
      deck = create(:deck, level: 1)
      create_list(:card, 10, deck:)
      card = described_class.new(deck:).next_card

      expect(deck.cards.not_done(1).ordered.limit(5)).to include(card)
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
      stub_const("Study::ACTIVE_CARD_THRESHOLD", 5)
      deck = create(:deck, level: 1)
      create_list(:card, 10, deck:)
      card = described_class.new(deck:).next_card

      expect(deck.cards.not_done(1).ordered.offset(5)).not_to include(card)
    end

    it "excludes the given card when others are available" do
      deck = create(:deck)
      create_list(:card, 3, deck:)
      excluded = deck.cards.first
      card = described_class.new(deck:, exclude_card_id: excluded.id).next_card

      expect(card).not_to eq(excluded)
    end

    it "returns the excluded card when it is the only one left" do
      deck = create(:deck)
      excluded = create(:card, deck:)

      study = described_class.new(deck:, exclude_card_id: excluded.id)

      expect(study.next_card).to eq(excluded)
    end
  end

  describe "#presentation_mode" do
    it "returns :multiple_choice below the fuzzy find level" do
      deck = create(:deck, level: described_class::FUZZY_FIND_LEVEL - 1)

      expect(described_class.new(deck:).presentation_mode)
        .to eq(:multiple_choice)
    end

    it "returns :fuzzy_find at the fuzzy find level" do
      deck = create(:deck, level: described_class::FUZZY_FIND_LEVEL)

      expect(described_class.new(deck:).presentation_mode).to eq(:fuzzy_find)
    end

    it "returns :fuzzy_find above the fuzzy find level" do
      deck = create(:deck, level: described_class::FUZZY_FIND_LEVEL + 1)

      expect(described_class.new(deck:).presentation_mode).to eq(:fuzzy_find)
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
      create(:card, deck:, distractors: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    it "includes second wrong answer from card history" do
      deck = create(:deck)
      create(:card, deck:, distractors: ["London", "Berlin"])

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
        create(:card, distractors: ["B"], **attrs)
        create(:card, back: "B", **attrs)
      end

      it "does not duplicate the answer" do
        answers = described_class.new(deck:).possible_answers

        expect(answers.tally.values).to all(eq(1))
      end
    end

    it "samples at most 4 wrong answers from the card's distractors" do
      deck = create(:deck)
      create(:card, deck:, distractors: ["A", "B", "C", "D", "E"])

      study = described_class.new(deck:)

      expect(study.possible_answers.size).to eq(5)
    end

    it "includes cards from other categories when needed" do
      deck = create(:deck)
      create(:card, deck:, back: "Paris", category: "Geography")
      create(:card, deck:, back: "Four", category: "Math")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Four")
    end

    context "when in fuzzy find mode" do
      let(:level) { Study::FUZZY_FIND_LEVEL }

      it "returns all back values for cards in the deck" do
        deck = create(:deck, level:)
        create(:card, deck:, back: "Paris", correct_streak: level - 1)
        create(:card, :done, deck:, back: "London")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to contain_exactly("Paris", "London")
      end

      it "deduplicates repeated back values" do
        deck = create(:deck, level:)
        create(:card, deck:, back: "Paris", correct_streak: level - 1)
        create(:card, :done, deck:, back: "Paris")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to eq(["Paris"])
      end
    end

    context "when deck distractor_pool is 'preset'" do
      it "uses only the card's own distractors" do
        deck = create(:deck, distractor_pool: "preset")
        create(:card, deck:, back: "Paris", distractors: ["London", "Berlin"])
        create(:card, :done, deck:, back: "Madrid")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to contain_exactly("Paris", "London", "Berlin")
      end

      it "shows fewer than 4 wrong choices when card has fewer distractors" do
        deck = create(:deck, distractor_pool: "preset")
        create(:card, deck:, back: "Paris", distractors: ["London"])
        create(:card, :done, deck:, back: "Madrid", category: "Geography")

        answers = described_class.new(deck:).possible_answers

        expect(answers).not_to include("Madrid")
      end

      it "shows only the correct answer when card has no distractors" do
        deck = create(:deck, distractor_pool: "preset")
        create(:card, deck:, back: "Paris", distractors: [])
        create(:card, :done, deck:, back: "Madrid")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to eq(["Paris"])
      end
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

      it "marks card as done when streak reaches deck level" do
        deck = create(:deck, level: 1)
        card = create(:card, deck:, back: "Paris")
        create(:card, deck:)
        answer_card(deck:, card:)

        expect(card.reload.done?).to be(true)
      end

      it "keeps card not done when streak below deck level" do
        deck = create(:deck, level: 5)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.done?).to be(false)
      end

      it "returns card_completed true when streak meets deck level" do
        deck = create(:deck, level: 1)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card_completed?).to be(true)
      end

      it "returns card_completed false when streak below deck level" do
        deck = create(:deck, level: 5)
        card = create(:card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card_completed?).to be(false)
      end

      it "returns level_completed true when last card is completed" do
        deck = create(:deck, level: 1)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.level_completed?).to be(true)
      end

      it "advances deck level when last card is completed" do
        deck = create(:deck, level: 1)
        card = create(:card, deck:, back: "Paris")
        answer_card(deck:, card:)

        expect(deck.reload.level).to eq(2)
      end

      it "returns level_completed false when other cards remain" do
        deck = create(:deck, level: 1)
        card = create(:card, deck:, back: "Paris")
        create(:card, deck:)

        result = answer_card(deck:, card:)

        expect(result.level_completed?).to be(false)
      end

      it "does not advance deck level when other cards remain" do
        deck = create(:deck, level: 1)
        card = create(:card, deck:, back: "Paris")
        create(:card, deck:)
        answer_card(deck:, card:)

        expect(deck.reload.level).to eq(1)
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

      it "includes the correct answer in result possible_answers" do
        deck = create(:deck)
        card = create(:card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.possible_answers).to include("Paris")
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

        expect(card.reload.distractors).to eq(["London"])
      end

      it "prepends wrong answer to existing list" do
        card = create(:card, back: "Paris", distractors: ["Berlin"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.distractors).to eq(["London", "Berlin"])
      end

      it "removes duplicate wrong answers" do
        card = create(:card, back: "Paris", distractors: ["London"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.distractors).to eq(["London"])
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

      it "includes the correct answer in result possible_answers" do
        card = create(:card, back: "Paris")
        result = answer_card(deck: card.deck, card:, answer: "London")

        expect(result.possible_answers).to include("Paris")
      end
    end
  end
end
