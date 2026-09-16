# frozen_string_literal: true

require "rails_helper"

# Exercised through ReadingCard - LanguageCard is never instantiated
# directly. Language cards keep nil content columns; the front side reads
# through the item's entry, the back side through the list's senses.
RSpec.describe LanguageCard do
  it "requires an item" do
    card = ReadingCard.new(deck: build(:reading_deck))

    card.valid?

    expect(card.errors[:item]).to be_present
  end

  it "reads the front from the entry despite nil columns" do
    card = create(:reading_card, front: "明白")

    expect(card).to have_attributes(front: "明白")
      .and(satisfy("column is nil") { |c| c[:front].nil? })
  end

  it "shares one entry with a card for the same word in another list" do
    card = create(:reading_card, front: "明白", reading: "míngbai")
    other = create(:reading_card, front: "明白", reading: "míngbai")

    expect(card.entry).to eq(other.entry)
  end

  it "rejoins the back from the list's senses in membership order" do
    card = create(:reading_card, back: "understand;clear")

    expect(card.back).to eq("understand; clear")
  end

  it "shows only the senses its own list selected" do
    card = create(:reading_card, front: "花", back: "flower")
    create(:reading_card, front: "花", back: "to spend")

    expect(card.back).to eq("flower")
  end

  describe ".backs" do
    it "rejoins each card's back from the list's senses in one query" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, back: "two;a couple")
      create(:reading_card, deck:, back: "three")

      expect(deck.cards.backs).to contain_exactly("two; a couple", "three")
    end

    it "limits itself to the scope" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, back: "two")
      excluded = create(:reading_card, deck:, back: "three")

      expect(deck.cards.where.not(id: excluded.id).backs).to eq(["two"])
    end

    it "shows only the senses its own list selected" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "花", back: "flower")
      create(:reading_card, front: "花", back: "to spend")

      expect(deck.cards.backs).to eq(["flower"])
    end
  end

  describe "#distractors" do
    def sense_of(card, gloss)
      Sense.find_by!(entry: card.entry, gloss:)
    end

    def another_users_miss(card, sibling)
      create(
        :sense_distractor,
        user: create(:user),
        sense: sense_of(card, "understand"),
        distractor_sense: sense_of(sibling, "happy"),
      )
    end

    it "reads the owner's remembered decoys" do
      card = create(:reading_card, distractors: ["happy", "run"])

      expect(card.distractors).to contain_exactly("happy", "run")
    end

    it "shows a decoy as the list's current glosses for its entry" do
      card = create(:reading_card, distractors: ["he; him"])
      decoy = Entry.find_by!(headword: "he; him")
      sense = create(:sense, entry: decoy, gloss: "his")
      card.deck.word_list.sense_memberships.create!(sense:, position: 99)

      expect(card.distractors).to eq(["he; him; his"])
    end

    it "ignores another user's misses" do
      card = create(:reading_card, back: "understand")
      sibling = create(:reading_card, deck: card.deck, back: "happy")
      another_users_miss(card, sibling)

      expect(card.distractors).to be_empty
    end

    it "lists a back once when two decoy entries share it" do
      card = create(:reading_card, front: "あ", back: "a")
      create(:reading_card, deck: card.deck, front: "い", back: "i")
      create(:reading_card, deck: card.deck, front: "イ", back: "i")

      card.record_miss!("i")

      expect(card.distractors).to eq(["i"])
    end

    it "drops a decoy whose entry the list no longer holds" do
      card = create(:reading_card, distractors: ["happy"])
      card.deck.word_list.sense_memberships.joins(:sense)
        .where(senses: { gloss: "happy" }).delete_all

      expect(card.distractors).to be_empty
    end
  end

  it "reads the reading from the entry and the category from the list" do
    card = create(:reading_card, reading: "míngbai")

    expect(card).to have_attributes(reading: "míngbai", category: "General")
  end

  it "reads the example pair from the senses" do
    card = create(:reading_card, example_front: "ef", example_back: "eb")

    expect(card).to have_attributes(example_front: "ef", example_back: "eb")
  end

  it "has no example when its senses hold none" do
    card = create(:reading_card)

    expect(card).to have_attributes(example_front: nil, example_back: nil)
  end

  describe "skill scores" do
    def counters
      SkillScore.pluck(:correct_count, :correct_streak, :view_count)
    end

    it "advances a score on each member sense with a correct answer" do
      card = create(:reading_card, back: "he; him")

      card.record_correct!

      expect(counters).to eq([[1, 1, 1]] * 2)
    end

    it "keys the score to the deck's owner and skill" do
      card = create(:reading_card, back: "he")

      card.record_correct!

      expect(SkillScore.sole)
        .to have_attributes(user: card.deck.user, skill: "reading")
    end

    it "resets the score's streak on a miss" do
      card = create(:reading_card, back: "he")

      card.record_correct!
      card.record_miss!

      expect(counters).to eq([[1, 0, 2]])
    end

    it "counts a view on the score" do
      card = create(:reading_card, back: "he")

      card.record_view!

      expect(counters).to eq([[0, 0, 1]])
    end

    it "builds on a score the sense already carries" do
      card = create(:reading_card, back: "he")
      sense = card.deck.word_list.senses.sole
      create(:skill_score, user: card.deck.user, sense:, correct_streak: 3)

      card.record_correct!

      expect(counters).to eq([[1, 4, 1]])
    end

    it "leaves the card's own counters authoritative" do
      card = create(:reading_card, back: "he")

      card.record_correct!

      expect(card.reload).to have_attributes(correct_streak: 1, view_count: 1)
    end
  end

  describe "#homograph?" do
    it "is true when another card's entry shares the headword" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, front: "过", reading: "guò")
      create(:reading_card, deck:, front: "过", reading: "guo")

      expect(card.homograph?).to be(true)
    end

    it "is false when no other card's entry shares the headword" do
      deck = create(:reading_deck)
      card = create(:reading_card, deck:, front: "过")
      create(:reading_card, deck:, front: "还")

      expect(card.homograph?).to be(false)
    end
  end

  describe "#record_miss!" do
    def gloss_pairs
      SenseDistractor.all.map { |d| [d.sense.gloss, d.distractor_sense.gloss] }
    end

    def pronoun_pairs
      [["he", "she"], ["he", "her"], ["him", "she"], ["him", "her"]]
    end

    it "links each shown sense to each chosen sense" do
      card = create(:reading_card, back: "he; him")
      create(:reading_card, deck: card.deck, back: "she; her")

      card.record_miss!("she; her")

      expect(gloss_pairs).to match_array(pronoun_pairs)
    end

    it "records the miss for the deck's owner" do
      card = create(:reading_card, back: "he")
      create(:reading_card, deck: card.deck, back: "she")

      card.record_miss!("she")

      expect(SenseDistractor.sole.user).to eq(card.deck.user)
    end

    it "makes the chosen back one of the card's distractors" do
      card = create(:reading_card, back: "he")
      create(:reading_card, deck: card.deck, back: "she")

      card.record_miss!("she")

      expect(card.distractors).to eq(["she"])
    end

    it "counts a repeated miss instead of adding a row" do
      card = create(:reading_card, back: "he")
      create(:reading_card, deck: card.deck, back: "she")

      2.times { card.record_miss!("she") }

      expect(SenseDistractor.sole.miss_count).to eq(2)
    end

    it "links every entry whose glosses rejoin to the chosen text" do
      card = create(:reading_card, front: "喜欢", back: "to like")
      create(:reading_card, deck: card.deck, front: "爱", back: "to love")
      create(:reading_card, deck: card.deck, front: "爱好", back: "to love")

      card.record_miss!("to love")

      expect(SenseDistractor.count).to eq(2)
    end

    it "records nothing when the text is only part of a sibling's back" do
      card = create(:reading_card, back: "he")
      create(:reading_card, deck: card.deck, back: "she; her")

      card.record_miss!("she")

      expect(SenseDistractor.count).to eq(0)
    end

    it "records nothing when the text matches no sibling" do
      card = create(:reading_card)

      card.record_miss!("wrong")

      expect(SenseDistractor.count).to eq(0)
    end

    it "does not write card_distractors" do
      card = create(:reading_card)
      card.record_miss!("wrong")

      expect(card.card_distractors).to be_empty
    end
  end
end
