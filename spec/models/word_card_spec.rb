# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordCard do
  def sense_of(card, gloss)
    card.deck.word_list.senses.find_by!(gloss:)
  end

  def counters
    SkillScore.pluck(:correct_count, :correct_streak, :view_count)
  end

  it "is keyed by the entry" do
    card = create(:word)

    expect(card.id).to eq(Entry.sole.id)
  end

  it "reads the front and reading from the entry" do
    card = create(:word, front: "明白", reading: "míngbai")

    expect(card).to have_attributes(front: "明白", reading: "míngbai")
  end

  it "rejoins the back from the list's senses in membership order" do
    card = create(:word, back: "understand;clear")

    expect(card.back).to eq("understand; clear")
  end

  it "shows only the senses its own list selected" do
    card = create(:word, front: "花", back: "flower")
    create(:word, front: "花", back: "to spend")

    expect(card.back).to eq("flower")
  end

  it "files under the list's category for the word" do
    card = create(:word, category: "Nature")

    expect(card.category).to eq("Nature")
  end

  it "shows the example a member sense holds" do
    card = create(:word, example_front: "一朵花", example_back: "A flower")

    expect(card)
      .to have_attributes(example_front: "一朵花", example_back: "A flower")
  end

  it "has no example when no sense carries one" do
    card = create(:word)

    expect(card).to have_attributes(example_front: nil, example_back: nil)
  end

  describe "#done?" do
    it "is true once the weakest sense reaches the level" do
      card = create(:word, :done)

      expect(card.done?).to be(true)
    end

    it "is false while any member sense sits below the level" do
      card = create(:word, back: "he; him")
      create(:skill_score, sense: sense_of(card, "he"), correct_streak: 1)

      expect(card.deck.card(card.id).done?).to be(false)
    end
  end

  describe "#homograph?" do
    it "is true when the list holds another reading of the headword" do
      card = create(:word, front: "过", reading: "guò")
      create(:word, deck: card.deck, front: "过", reading: "guo")

      expect(card.homograph?).to be(true)
    end
  end

  describe "#distractors" do
    def remember(card, front:, back:)
      decoy = create(:word, deck: card.deck, front:, back:)
      create(
        :sense_distractor,
        user: card.deck.user,
        sense: sense_of(card, card.back),
        distractor_sense: Sense.find_by!(entry_id: decoy.id),
      )
    end

    it "rejoins the backs of the owner's remembered decoys" do
      card = create(:word, distractors: ["London; Londres"])

      expect(card.distractors).to eq(["London; Londres"])
    end

    it "drops a decoy whose entry left the list" do
      card = create(:word, distractors: ["London"])
      SenseDistractor.sole.distractor_sense.sense_memberships.delete_all

      expect(card.distractors).to eq([])
    end

    it "shows entries sharing a back once" do
      card = create(:word, front: "x", back: "ex")
      remember(card, front: "い", back: "i")
      remember(card, front: "イ", back: "i")

      expect(card.distractors).to eq(["i"])
    end
  end

  describe "#record_correct!" do
    it "advances a score on every member sense" do
      card = create(:word, back: "he; him")

      card.record_correct!

      expect(counters).to eq([[1, 1, 1]] * 2)
    end

    it "keys the score to the deck's owner and skill" do
      card = create(:word)

      card.record_correct!

      expect(SkillScore.sole)
        .to have_attributes(user: card.deck.user, skill: "reading")
    end

    it "builds on a score the sense already carries" do
      card = create(:word, correct_streak: 3)

      card.record_correct!

      expect(counters).to eq([[1, 4, 1]])
    end

    it "advances its own streak" do
      card = create(:word)

      card.record_correct!

      expect(card.correct_streak).to eq(1)
    end
  end

  describe "#record_miss!" do
    def gloss_pairs
      SenseDistractor.all.map { |d| [d.sense.gloss, d.distractor_sense.gloss] }
    end

    def pronoun_pairs
      [["he", "she"], ["he", "her"], ["him", "she"], ["him", "her"]]
    end

    it "resets the score's streak and counts the view" do
      card = create(:word, correct_count: 2, correct_streak: 2, view_count: 2)

      card.record_miss!

      expect(counters).to eq([[2, 0, 3]])
    end

    it "resets its own streak" do
      card = create(:word, correct_streak: 2)

      card.record_miss!

      expect(card.correct_streak).to eq(0)
    end

    it "links each shown sense to each chosen sense" do
      card = create(:word, back: "he; him")
      create(:word, deck: card.deck, back: "she; her")

      card.record_miss!("she; her")

      expect(gloss_pairs).to match_array(pronoun_pairs)
    end

    it "records the miss for the deck's owner" do
      card = create(:word, back: "he")
      create(:word, deck: card.deck, back: "she")

      card.record_miss!("she")

      expect(SenseDistractor.sole.user).to eq(card.deck.user)
    end

    it "makes the chosen back one of the card's distractors" do
      card = create(:word, back: "he")
      create(:word, deck: card.deck, back: "she")

      card.record_miss!("she")

      expect(card.distractors).to eq(["she"])
    end

    it "counts a repeated miss instead of adding a row" do
      card = create(:word, back: "he")
      create(:word, deck: card.deck, back: "she")

      2.times { card.record_miss!("she") }

      expect(SenseDistractor.sole.miss_count).to eq(2)
    end

    it "ignores a chosen answer that matches no sibling's back" do
      card = create(:word, back: "he")
      create(:word, deck: card.deck, back: "she; her")

      card.record_miss!("she")

      expect(SenseDistractor.count).to eq(0)
    end

    it "records no distractor without a chosen answer" do
      card = create(:word, back: "he")

      card.record_miss!

      expect(SenseDistractor.count).to eq(0)
    end
  end
end
