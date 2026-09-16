# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordCard do
  def word_card(card) = card.deck.card(card.entry.id)

  def sense_of(card, gloss)
    card.deck.word_list.senses.find_by!(gloss:)
  end

  it "is keyed by the entry" do
    card = create(:reading_card)

    expect(word_card(card).id).to eq(card.entry.id)
  end

  it "reads the front and reading from the entry" do
    card = create(:reading_card, front: "明白", reading: "míngbai")

    expect(word_card(card)).to have_attributes(front: "明白", reading: "míngbai")
  end

  it "rejoins the back from the list's senses in membership order" do
    card = create(:reading_card, back: "understand;clear")

    expect(word_card(card).back).to eq("understand; clear")
  end

  it "shows only the senses its own list selected" do
    card = create(:reading_card, front: "花", back: "flower")
    create(:reading_card, front: "花", back: "to spend")

    expect(word_card(card).back).to eq("flower")
  end

  it "files under the list's category for the word" do
    card = create(:reading_card, category: "Nature")

    expect(word_card(card).category).to eq("Nature")
  end

  it "shows the example a member sense holds" do
    card = create(:reading_card, example_front: "一朵花", example_back: "A flower")

    expect(word_card(card))
      .to have_attributes(example_front: "一朵花", example_back: "A flower")
  end

  it "has no example when no sense carries one" do
    card = create(:reading_card)

    expect(word_card(card))
      .to have_attributes(example_front: nil, example_back: nil)
  end

  describe "#done?" do
    it "is true once the weakest sense reaches the level" do
      card = create(:reading_card, :done)

      expect(word_card(card).done?).to be(true)
    end

    it "is false while any member sense sits below the level" do
      card = create(:reading_card, back: "he; him")
      create(:skill_score, sense: sense_of(card, "he"), correct_streak: 1)

      expect(word_card(card).done?).to be(false)
    end
  end

  describe "#homograph?" do
    it "is true when the list holds another reading of the headword" do
      card = create(:reading_card, front: "过", reading: "guò")
      create(:reading_card, deck: card.deck, front: "过", reading: "guo")

      expect(word_card(card).homograph?).to be(true)
    end
  end

  describe "#distractors" do
    def remember(card, front:, back:)
      decoy = create(:reading_card, deck: card.deck, front:, back:)
      senses = decoy.deck.word_list.senses
      create(
        :sense_distractor,
        user: card.deck.user,
        sense: sense_of(card, card.back),
        distractor_sense: senses.find_by!(entry: decoy.entry),
      )
    end

    it "rejoins the backs of the owner's remembered decoys" do
      card = create(:reading_card, distractors: ["London; Londres"])

      expect(word_card(card).distractors).to eq(["London; Londres"])
    end

    it "drops a decoy whose entry left the list" do
      card = create(:reading_card, distractors: ["London"])
      SenseDistractor.sole.distractor_sense.sense_memberships.delete_all

      expect(word_card(card).distractors).to eq([])
    end

    it "shows entries sharing a back once" do
      card = create(:reading_card, front: "x", back: "ex")
      remember(card, front: "い", back: "i")
      remember(card, front: "イ", back: "i")

      expect(word_card(card).distractors).to eq(["i"])
    end
  end

  describe "#record_correct!" do
    it "writes through the deck's card row" do
      card = create(:reading_card)

      word_card(card).record_correct!

      expect(card.reload).to have_attributes(correct_streak: 1, view_count: 1)
    end

    it "advances the score of every member sense" do
      card = create(:reading_card, back: "he; him")

      word_card(card).record_correct!

      expect(SkillScore.pluck(:correct_streak)).to eq([1, 1])
    end

    it "advances its own streak" do
      card = word_card(create(:reading_card))

      card.record_correct!

      expect(card.correct_streak).to eq(1)
    end
  end

  describe "#record_miss!" do
    it "remembers the chosen answer for the deck's owner" do
      card = create(:reading_card, back: "he")
      create(:reading_card, deck: card.deck, back: "she")

      word_card(card).record_miss!("she")

      expect(word_card(card).distractors).to eq(["she"])
    end

    it "resets its own streak" do
      card = word_card(create(:reading_card, correct_streak: 2))

      card.record_miss!

      expect(card.correct_streak).to eq(0)
    end
  end
end
