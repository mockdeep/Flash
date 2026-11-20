# frozen_string_literal: true

RSpec.describe Heat do
  def heat_of(deck, user: default_user)
    described_class.for(user, [deck.word_list_id])[deck.word_list_id]
  end

  # Another deck whose list holds the card's first sense.
  def deck_sharing(card)
    sense = Sense.find(card.sense_ids.first)
    other = create(:reading_deck)
    create(:sense_membership, sense:, word_list: other.word_list)
    other
  end

  describe ".for" do
    it "counts a list's entries" do
      deck = create(:reading_deck)
      create_list(:language_card, 2, deck:)

      expect(heat_of(deck).total).to eq(2)
    end

    it "counts an entry with several senses once" do
      deck = create(:reading_deck)
      create(:language_card, deck:, back: "flower; to spend")

      expect(heat_of(deck).total).to eq(1)
    end

    it "knows nothing of a list with no scores" do
      deck = create(:reading_deck)
      create(:language_card, deck:)

      expect(heat_of(deck).known).to eq(0)
    end

    it "knows a third of a word at a streak of 1" do
      deck = create(:reading_deck)
      create(:language_card, deck:, correct_streak: 1)

      expect(heat_of(deck).known).to eq(1.fdiv(3))
    end

    it "knows a whole word at a streak of 3" do
      deck = create(:reading_deck)
      create(:language_card, deck:, correct_streak: 3)

      expect(heat_of(deck).known).to eq(1)
    end

    it "knows no more than a whole word past a streak of 3" do
      deck = create(:reading_deck)
      create(:language_card, deck:, correct_streak: 5)

      expect(heat_of(deck).known).to eq(1)
    end

    it "takes the weakest streak among an entry's senses" do
      deck = create(:reading_deck)
      card = create(:language_card, deck:, back: "flower; to spend")
      create(:skill_score, sense_id: card.sense_ids.first, correct_streak: 3)

      expect(heat_of(deck).known).to eq(0)
    end

    it "counts a word learned in another deck" do
      card = create(:language_card, correct_streak: 3)

      expect(heat_of(deck_sharing(card)).known).to eq(1)
    end

    it "leaves out a sense the list doesn't hold" do
      card = create(:language_card, back: "flower; to spend")
      create(:skill_score, sense_id: card.sense_ids.first, correct_streak: 3)

      expect(heat_of(deck_sharing(card)).known).to eq(1)
    end

    it "leaves out another learner's scores" do
      deck = create(:reading_deck)
      create(:language_card, deck:, correct_streak: 3)

      expect(heat_of(deck, user: create(:user)).known).to eq(0)
    end

    it "has no heat for a list with no words" do
      deck = create(:reading_deck)

      expect(heat_of(deck)).to be_nil
    end

    it "keeps each list's heat apart" do
      decks = create_list(:reading_deck, 2)
      create(:language_card, deck: decks.first)
      create_list(:language_card, 2, deck: decks.last)
      heats = described_class.for(default_user, decks.map(&:word_list_id))

      expect(heats.values.map(&:total)).to contain_exactly(1, 2)
    end
  end

  describe "#percent" do
    it "gives the share known as a whole number" do
      expect(described_class.new(total: 2, steps: 3).percent).to eq(50)
    end

    it "rounds down" do
      expect(described_class.new(total: 3, steps: 8).percent).to eq(88)
    end
  end
end
