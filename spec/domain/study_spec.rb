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
      create(:basic_card, deck:)

      study = described_class.new(deck:)

      expect(study.next_card).to be_a(Card)
    end

    it "limits cards to threshold" do
      stub_const("Study::ACTIVE_CARD_THRESHOLD", 5)
      deck = create(:deck, level: 1)
      create_list(:basic_card, 10, deck:)
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
      create(:basic_card, :done, deck:)

      study = described_class.new(deck:)

      expect(study.next_card).to be_nil
    end

    it "does not return cards beyond the threshold" do
      stub_const("Study::ACTIVE_CARD_THRESHOLD", 5)
      deck = create(:deck, level: 1)
      create_list(:basic_card, 10, deck:)
      card = described_class.new(deck:).next_card

      expect(deck.cards.not_done(1).ordered.offset(5)).not_to include(card)
    end

    it "excludes the given card when others are available" do
      deck = create(:deck)
      create_list(:basic_card, 3, deck:)
      excluded = deck.cards.first
      card = described_class.new(deck:, exclude_card_id: excluded.id).next_card

      expect(card).not_to eq(excluded)
    end

    it "returns the excluded card when it is the only one left" do
      deck = create(:deck)
      excluded = create(:basic_card, deck:)

      study = described_class.new(deck:, exclude_card_id: excluded.id)

      expect(study.next_card).to eq(excluded)
    end

    it "pins next_card to the given card_id" do
      deck = create(:deck)
      card = create(:basic_card, deck:)
      create(:basic_card, deck:)

      study = described_class.new(deck:, card_id: card.id)

      expect(study.next_card).to eq(card)
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

    context "when the deck is at the reading level" do
      def reading_level_deck
        create(:deck, level: described_class::READING_LEVEL)
      end

      it "returns :reading when the next card has a reading" do
        deck = reading_level_deck
        create(:basic_card, deck:, reading: "liǎng")

        expect(described_class.new(deck:).presentation_mode).to eq(:reading)
      end

      it "returns :multiple_choice when the next card has no reading" do
        deck = reading_level_deck
        create(:basic_card, deck:)

        expect(described_class.new(deck:).presentation_mode)
          .to eq(:multiple_choice)
      end

      it "returns :multiple_choice when pinned to a card by card_id" do
        deck = reading_level_deck
        card = create(:basic_card, deck:, reading: "liǎng")

        study = described_class.new(deck:, card_id: card.id)

        expect(study.presentation_mode).to eq(:multiple_choice)
      end
    end

    it "returns :multiple_choice below the reading level" do
      deck = create(:deck, level: described_class::READING_LEVEL - 1)
      create(:basic_card, deck:, reading: "liǎng")

      expect(described_class.new(deck:).presentation_mode)
        .to eq(:multiple_choice)
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
      create(:basic_card, deck:, back: "Paris")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Paris")
    end

    it "includes first wrong answer from card history" do
      deck = create(:deck)
      create(:basic_card, deck:, distractors: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    it "includes second wrong answer from card history" do
      deck = create(:deck)
      create(:basic_card, deck:, distractors: ["London", "Berlin"])

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Berlin")
    end

    it "includes cards from same category" do
      deck = create(:deck)
      create(:basic_card, deck:, back: "Paris", category: "Geography")
      create(:basic_card, deck:, back: "London", category: "Geography")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("London")
    end

    context "when wrong answer matches a same-category card" do
      it "does not duplicate the answer" do
        deck = create(:deck)
        create(:basic_card, deck:, category: "Geo", distractors: ["B"])
        create(:basic_card, deck:, category: "Geo", back: "B")

        answers = described_class.new(deck:).possible_answers

        expect(answers.tally.values).to all(eq(1))
      end
    end

    it "samples at most 4 wrong answers from the card's distractors" do
      deck = create(:deck)
      create(:basic_card, deck:, distractors: ["A", "B", "C", "D", "E"])

      study = described_class.new(deck:)

      expect(study.possible_answers.size).to eq(5)
    end

    it "includes cards from other categories when needed" do
      deck = create(:deck)
      create(:basic_card, deck:, back: "Paris", category: "Geography")
      create(:basic_card, deck:, back: "Four", category: "Math")

      study = described_class.new(deck:)

      expect(study.possible_answers).to include("Four")
    end

    context "when in fuzzy find mode" do
      def fuzzy_find_deck
        create(:deck, level: Study::FUZZY_FIND_LEVEL)
      end

      def almost_done_card(deck, back)
        create(:basic_card, deck:, back:, correct_streak: deck.level - 1)
      end

      it "returns all back values for cards in the deck" do
        deck = fuzzy_find_deck
        almost_done_card(deck, "Paris")
        create(:basic_card, :done, deck:, back: "London")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to contain_exactly("Paris", "London")
      end

      it "deduplicates repeated back values" do
        deck = fuzzy_find_deck
        almost_done_card(deck, "Paris")
        create(:basic_card, :done, deck:, back: "Paris")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to eq(["Paris"])
      end
    end

    context "when in reading mode" do
      # A reading-level deck holding the prompt card the study will pick.
      def deck_with_prompt(front:, reading:)
        deck = create(:deck, level: Study::READING_LEVEL)
        create(:basic_card, deck:, front:, reading:)
        deck
      end

      it "includes the card's reading" do
        deck = deck_with_prompt(front: "两", reading: "liǎng")

        expect(described_class.new(deck:).possible_answers).to include("liǎng")
      end

      it "uses sibling readings as decoys" do
        deck = deck_with_prompt(front: "两", reading: "liǎng")
        create(:basic_card, :done, deck:, reading: "sān")

        expect(described_class.new(deck:).possible_answers)
          .to contain_exactly("liǎng", "sān")
      end

      it "excludes sibling readings equal to the card's own" do
        deck = deck_with_prompt(front: "是", reading: "shì")
        create(:basic_card, :done, deck:, reading: "shì")

        expect(described_class.new(deck:).possible_answers).to eq(["shì"])
      end

      it "skips siblings without a reading" do
        deck = deck_with_prompt(front: "两", reading: "liǎng")
        create(:basic_card, :done, deck:)

        expect(described_class.new(deck:).possible_answers).to eq(["liǎng"])
      end

      it "deduplicates repeated sibling readings" do
        deck = deck_with_prompt(front: "两", reading: "liǎng")
        create(:basic_card, :done, deck:, reading: "sān")
        create(:basic_card, :done, deck:, reading: "sān")

        answers = described_class.new(deck:).possible_answers

        expect(answers.tally.values).to all(eq(1))
      end

      def create_siblings(deck, readings)
        readings.each { |reading| create(:basic_card, :done, deck:, reading:) }
      end

      it "prefers decoys whose front matches the prompt's character count" do
        deck = deck_with_prompt(front: "学生", reading: "abcd")
        create(:basic_card, :done, deck:, front: "九十百千万", reading: "uvwx")
        create_filler_siblings(deck)

        expect(described_class.new(deck:).possible_answers)
          .not_to include("uvwx")
      end

      it "offers at most five options" do
        deck = deck_with_prompt(front: "妈", reading: "mā")
        create_siblings(deck, ["bà", "gē", "dì", "yī", "èr"])

        expect(described_class.new(deck:).possible_answers.size).to eq(5)
      end

      def create_reading_siblings(deck, pairs)
        pairs.each do |front, reading|
          create(:basic_card, :done, deck:, front:, reading:)
        end
      end

      # Four filler siblings with two-character fronts that share no character
      # with the prompts below.
      def create_filler_siblings(deck)
        fillers =
          [["一二", "efgh"], ["三四", "ijkl"], ["五六", "mnop"], ["七八", "qrst"]]
        create_reading_siblings(deck, fillers)
      end

      # The single-character version of the fillers above.
      def create_single_char_fillers(deck)
        pairs = [["一", "efgh"], ["二", "ijkl"], ["三", "mnop"], ["四", "qrst"]]
        create_reading_siblings(deck, pairs)
      end

      it "anchors a decoy on the prompt's first character" do
        deck = deck_with_prompt(front: "学生", reading: "abcd")
        create(:basic_card, :done, deck:, front: "学校", reading: "abzzzz")
        create_filler_siblings(deck)

        expect(described_class.new(deck:).possible_answers).to include("abzzzz")
      end

      it "anchors a decoy on the prompt's last character" do
        deck = deck_with_prompt(front: "学生", reading: "abcd")
        create(:basic_card, :done, deck:, front: "先生", reading: "zzzzcd")
        create_filler_siblings(deck)

        expect(described_class.new(deck:).possible_answers).to include("zzzzcd")
      end

      it "does not anchor decoys for a single-character prompt" do
        deck = deck_with_prompt(front: "人", reading: "abcd")
        create(:basic_card, :done, deck:, front: "人们", reading: "abzzzz")
        create_single_char_fillers(deck)

        expect(described_class.new(deck:).possible_answers)
          .not_to include("abzzzz")
      end

      it "does not anchor a shared-character sibling of a different count" do
        deck = deck_with_prompt(front: "学生", reading: "abcd")
        create(:basic_card, :done, deck:, front: "学校图书馆", reading: "abzzzz")
        create_filler_siblings(deck)

        expect(described_class.new(deck:).possible_answers)
          .not_to include("abzzzz")
      end

      it "does not duplicate a sibling matching both ends of the prompt" do
        deck = deck_with_prompt(front: "人中人", reading: "aa")
        create(:basic_card, :done, deck:, front: "人间人", reading: "bb")

        answers = described_class.new(deck:).possible_answers

        expect(answers.tally.values).to all(eq(1))
      end
    end

    context "when deck distractor_pool is 'preset'" do
      def paris_card(deck, distractors)
        create(:basic_card, deck:, back: "Paris", distractors:)
      end

      it "uses only the card's own distractors" do
        deck = create(:deck, distractor_pool: "preset")
        paris_card(deck, ["London", "Berlin"])
        create(:basic_card, :done, deck:, back: "Madrid")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to contain_exactly("Paris", "London", "Berlin")
      end

      it "shows fewer than 4 wrong choices when card has fewer distractors" do
        deck = create(:deck, distractor_pool: "preset")
        paris_card(deck, ["London"])
        create(:basic_card, :done, deck:, back: "Madrid", category: "Geography")

        answers = described_class.new(deck:).possible_answers

        expect(answers).not_to include("Madrid")
      end

      it "shows only the correct answer when card has no distractors" do
        deck = create(:deck, distractor_pool: "preset")
        paris_card(deck, [])
        create(:basic_card, :done, deck:, back: "Madrid")

        answers = described_class.new(deck:).possible_answers

        expect(answers).to eq(["Paris"])
      end
    end
  end

  describe "#answer_reading" do
    def reading_card(**attrs)
      deck = create(:deck, level: Study::READING_LEVEL)
      create(:basic_card, deck:, reading: "liǎng", **attrs)
    end

    def answer_reading(card:, answer:)
      described_class.new(deck: card.deck)
        .answer_reading(card_id: card.id, answer:)
    end

    context "when the reading is correct" do
      it "returns reading_passed true" do
        card = reading_card

        result = answer_reading(card:, answer: "liǎng")

        expect(result.reading_passed?).to be(true)
      end

      it "returns correct true" do
        card = reading_card

        result = answer_reading(card:, answer: "liǎng")

        expect(result.correct?).to be(true)
      end

      it "does not change the view count" do
        card = reading_card

        expect { answer_reading(card:, answer: "liǎng") }
          .to not_change_record(card, :view_count)
      end

      it "does not change the correct streak" do
        card = reading_card(correct_streak: 1)

        expect { answer_reading(card:, answer: "liǎng") }
          .to not_change_record(card, :correct_streak)
      end

      it "does not record a distractor" do
        card = reading_card

        expect { answer_reading(card:, answer: "liǎng") }
          .to(not_change { card.reload.distractors })
      end
    end

    context "when the reading is wrong" do
      it "returns reading_passed false" do
        card = reading_card

        result = answer_reading(card:, answer: "sān")

        expect(result.reading_passed?).to be(false)
      end

      it "returns correct false" do
        card = reading_card

        result = answer_reading(card:, answer: "sān")

        expect(result.correct?).to be(false)
      end

      it "resets the correct streak" do
        card = reading_card(correct_streak: 1)

        expect { answer_reading(card:, answer: "sān") }
          .to change_record(card, :correct_streak).from(1).to(0)
      end

      it "increments the view count" do
        card = reading_card(view_count: 0)

        expect { answer_reading(card:, answer: "sān") }
          .to change_record(card, :view_count).from(0).to(1)
      end

      it "does not record the wrong reading as a distractor" do
        card = reading_card

        expect { answer_reading(card:, answer: "sān") }
          .to(not_change { card.reload.distractors })
      end

      it "returns the reading as the correct answer" do
        card = reading_card

        result = answer_reading(card:, answer: "sān")

        expect(result.correct_answer).to eq("liǎng")
      end

      it "includes the reading in result possible_answers" do
        card = reading_card

        result = answer_reading(card:, answer: "sān")

        expect(result.possible_answers).to include("liǎng")
      end
    end
  end

  describe "#answer_card" do
    context "when answer is correct" do
      it "increments view count" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris", view_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.view_count).to eq(1)
      end

      it "increments correct count" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris", correct_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.correct_count).to eq(1)
      end

      it "increments correct streak" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.correct_streak).to eq(1)
      end

      it "marks card as done when streak reaches deck level" do
        deck = create(:deck, level: 1)
        card = create(:basic_card, deck:, back: "Paris")
        create(:basic_card, deck:)
        answer_card(deck:, card:)

        expect(card.reload.done?).to be(true)
      end

      it "keeps card not done when streak below deck level" do
        deck = create(:deck, level: 5)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "Paris")

        expect(card.reload.done?).to be(false)
      end

      it "returns card_completed true when streak meets deck level" do
        deck = create(:deck, level: 1)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card_completed?).to be(true)
      end

      it "returns card_completed false when streak below deck level" do
        deck = create(:deck, level: 5)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 0)
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card_completed?).to be(false)
      end

      it "returns level_completed true when last card is completed" do
        deck = create(:deck, level: 1)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.level_completed?).to be(true)
      end

      it "advances deck level when last card is completed" do
        deck = create(:deck, level: 1)
        card = create(:basic_card, deck:, back: "Paris")
        answer_card(deck:, card:)

        expect(deck.reload.level).to eq(2)
      end

      it "returns level_completed false when other cards remain" do
        deck = create(:deck, level: 1)
        card = create(:basic_card, deck:, back: "Paris")
        create(:basic_card, deck:)

        result = answer_card(deck:, card:)

        expect(result.level_completed?).to be(false)
      end

      it "does not advance deck level when other cards remain" do
        deck = create(:deck, level: 1)
        card = create(:basic_card, deck:, back: "Paris")
        create(:basic_card, deck:)
        answer_card(deck:, card:)

        expect(deck.reload.level).to eq(1)
      end

      it "returns result with correct true" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.correct?).to be(true)
      end

      it "returns result with correct answer" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.correct_answer).to eq("Paris")
      end

      it "returns result with question" do
        deck = create(:deck)
        card = create(:basic_card, deck:, front: "Capital?", back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.question).to eq("Capital?")
      end

      it "returns result with the answered card" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.card).to eq(card)
      end

      it "includes the correct answer in result possible_answers" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "Paris")

        expect(result.possible_answers).to include("Paris")
      end
    end

    context "when answer is incorrect" do
      it "increments view count" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris", view_count: 0)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.view_count).to eq(1)
      end

      it "resets correct streak" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris", correct_streak: 5)
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.correct_streak).to eq(0)
      end

      it "adds wrong answer to card" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.distractors).to eq(["London"])
      end

      it "records the new distractor in the word_list" do
        card = create(:basic_card, back: "Paris")
        described_class.new(deck: card.deck)
          .answer_card(card_id: card.id, answer: "London")

        expect(card.reload.distractors).to include("London")
      end

      it "adds the wrong answer to the existing distractors" do
        card = create(:basic_card, back: "Paris", distractors: ["Berlin"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.distractors).to contain_exactly("London", "Berlin")
      end

      it "removes duplicate wrong answers" do
        card = create(:basic_card, back: "Paris", distractors: ["London"])
        study = described_class.new(deck: card.deck)

        study.answer_card(card_id: card.id, answer: "London")

        expect(card.reload.distractors).to eq(["London"])
      end

      it "returns result with card_completed false" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.card_completed?).to be(false)
      end

      it "returns result with correct false" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.correct?).to be(false)
      end

      it "returns result with correct answer" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.correct_answer).to eq("Paris")
      end

      it "returns result with question" do
        deck = create(:deck)
        card = create(:basic_card, deck:, front: "Capital?", back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.question).to eq("Capital?")
      end

      it "returns result with the answered card" do
        deck = create(:deck)
        card = create(:basic_card, deck:, back: "Paris")
        study = described_class.new(deck:)

        result = study.answer_card(card_id: card.id, answer: "London")

        expect(result.card).to eq(card)
      end

      it "includes the correct answer in result possible_answers" do
        card = create(:basic_card, back: "Paris")
        result = answer_card(deck: card.deck, card:, answer: "London")

        expect(result.possible_answers).to include("Paris")
      end
    end
  end
end
