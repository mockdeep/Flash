# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::BackfillSkillScores do
  # A card in its own deck and list, owned by the default user; two calls
  # with the same front, reading and back share an entry and a sense.
  def card(**attrs)
    create(:reading_card, front: "花", reading: "huā", back: "flower", **attrs)
  end

  def backfill
    described_class.call(dry_run: false)
  end

  def counters
    SkillScore.pluck(:correct_count, :correct_streak, :view_count)
  end

  it "seeds a reading score per member sense from the card's counters" do
    card(back: "flower; blossom", correct_count: 2, view_count: 3)

    backfill

    expect(counters).to eq([[2, 0, 3]] * 2)
  end

  it "keys the score to the deck's owner" do
    flower = card

    backfill

    expect(SkillScore.sole)
      .to have_attributes(user: flower.deck.user, skill: "reading")
  end

  it "keeps the greater counter across a user's cards sharing a sense" do
    card(correct_count: 3, correct_streak: 0, view_count: 3)
    card(correct_count: 1, correct_streak: 1, view_count: 1)

    backfill

    expect(counters).to eq([[3, 1, 3]])
  end

  it "scores each user's cards separately" do
    card
    card(deck: create(:reading_deck, user: create(:user)))

    backfill

    expect(SkillScore.count).to eq(2)
  end

  it "merges with a score the dual-write already wrote" do
    flower = card(correct_streak: 2)
    sense = flower.deck.word_list.senses.sole
    create(:skill_score, sense:, view_count: 5)

    backfill

    expect(counters).to eq([[0, 2, 5]])
  end

  it "ignores flat cards" do
    create(:basic_card, correct_streak: 2)

    backfill

    expect(SkillScore.count).to eq(0)
  end

  it "writes nothing on a dry run" do
    card

    described_class.call

    expect(SkillScore.count).to eq(0)
  end

  describe "the report" do
    it "counts the scores written" do
      card(back: "flower; blossom")

      expect(backfill.scores).to eq(2)
    end

    it "counts senses whose cards disagreed" do
      card(correct_streak: 2)
      card(correct_streak: 1)

      expect(backfill.disagreeing_senses).to eq(1)
    end

    it "counts cards whose list selects no sense for their entry" do
      flower = card
      flower.deck.word_list.sense_memberships.delete_all

      expect(backfill.orphan_cards).to eq(1)
    end

    it "finds no score short of its card after the run" do
      card(correct_streak: 2)

      expect(backfill.short_scores).to eq(0)
    end
  end
end
