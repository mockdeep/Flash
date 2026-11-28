# frozen_string_literal: true

RSpec.describe ReadingMap::Started do
  def started = described_class.new(decks: default_user.decks, language: "zh")

  def level_lists(*levels)
    levels.each { create(:word_list, curriculum: true, level: it) }
  end

  # The learner's deck over a new list with these attributes, with a card
  # to study.
  def deck_over(deck = {}, **list)
    deck = create(:reading_deck, word_list: create(:word_list, **list), **deck)
    deck.tap { create(:language_card, deck:) }
  end

  def met_goal(deck)
    count = deck.study_goal
    deck.study_days.create!(studied_on: Date.current, completed_count: count)
  end

  # Its words all answered right today.
  def waiting_for_tomorrow(deck)
    user = deck.user
    deck.word_list.senses.each do |sense|
      SkillScore.find_or_initialize_by(user:, sense:, skill: "reading")
        .update!(correct_streak: 1, last_correct_at: Time.current)
    end
  end

  describe "#decks" do
    it "gives the learner's decks over a list" do
      deck = deck_over

      expect(started.decks(deck.word_list_id)).to eq([deck])
    end

    it "gives none for a list the learner hasn't started" do
      expect(started.decks(create(:word_list).id)).to be_empty
    end
  end

  describe "#unmet_decks" do
    it "gives a deck short of today's goal" do
      deck = deck_over

      expect(started.unmet_decks(deck.word_list_id)).to eq([deck])
    end

    it "leaves out a deck that has met its goal" do
      deck = deck_over
      met_goal(deck)

      expect(started.unmet_decks(deck.word_list_id)).to be_empty
    end

    it "leaves out a deck waiting for tomorrow" do
      deck = deck_over
      waiting_for_tomorrow(deck)

      expect(started.unmet_decks(deck.word_list_id)).to be_empty
    end

    it "leaves out a deck with no goal" do
      deck = deck_over({ goal_mode: "none" })

      expect(started.unmet_decks(deck.word_list_id)).to be_empty
    end
  end

  describe "#next_deck" do
    it "is the unmet deck on the innermost ring" do
      level_lists(1, 2)
      decks = [2, 1].map { deck_over(level: it) }

      expect(started.next_deck).to eq(decks.last)
    end

    it "is the most recently studied of the decks on one ring" do
      decks = [2, 1].map { deck_over({ last_studied_at: it.days.ago }) }

      expect(started.next_deck).to eq(decks.last)
    end

    it "is the first by name of the decks never studied" do
      decks = ["B", "A"].map { deck_over(name: it) }

      expect(started.next_deck).to eq(decks.last)
    end

    it "puts a deck never studied after one that has been" do
      decks = [deck_over(name: "A"), deck_over({ last_studied_at: 1.day.ago })]

      expect(started.next_deck).to eq(decks.last)
    end

    it "passes over a list whose deck waits for tomorrow" do
      level_lists(1, 2)
      decks = [1, 2].map { deck_over(level: it) }
      waiting_for_tomorrow(decks.first)

      expect(started.next_deck).to eq(decks.last)
    end

    it "is nothing once every goal is met" do
      met_goal(deck_over)

      expect(started.next_deck).to be_nil
    end

    it "is nothing with nothing started" do
      expect(started.next_deck).to be_nil
    end
  end

  describe "#next_list" do
    it "is the list of the next deck" do
      level_lists(1, 2)
      decks = [2, 1].map { deck_over(level: it) }

      expect(started.next_list).to eq(decks.last.word_list)
    end

    it "is the most recently studied list once every goal is met" do
      decks = [2, 1].map { deck_over({ last_studied_at: it.days.ago }) }
      decks.each { met_goal(it) }

      expect(started.next_list).to eq(decks.last.word_list)
    end

    it "is nothing with nothing started" do
      expect(started.next_list).to be_nil
    end
  end
end
