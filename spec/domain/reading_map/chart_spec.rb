# frozen_string_literal: true

RSpec.describe ReadingMap::Chart do
  def chart(language: "zh", user: default_user)
    described_class.new(user:, language:)
  end

  # A public list with one word and a place on the map.
  def placed_list(**)
    list = create(:word_list, visibility: "public", angle: 90, **)
    create(:sense_membership, word_list: list)
    list
  end

  def level_list(level, **)
    placed_list(curriculum: true, level:, angle: nil, **)
  end

  def link(lists)
    word_list, linked_word_list = lists

    create(:word_list_link, word_list:, linked_word_list:)
  end

  def source_list(snippet: :finished, **)
    list = placed_list(**)
    create(:snippet, *snippet, source: create(:source, word_list: list))
    list
  end

  def lists_on_map(...) = chart(...).nodes.map(&:word_list)

  describe "#name" do
    it "is the language's name" do
      expect(chart.name).to eq("Mandarin")
    end
  end

  describe "#rings" do
    it "has a ring per level and one past the top" do
      [1, 2].each { level_list(it) }

      expect(chart.rings).to eq(3)
    end

    it "has one ring in a language with no level lists" do
      expect(chart.rings).to eq(1)
    end
  end

  describe "#lines" do
    it "has a line per level" do
      [1, 2].each { level_list(it) }

      expect(chart.lines).to eq(2)
    end

    it "has one line in a language with no level lists" do
      expect(chart.lines).to eq(1)
    end
  end

  describe "#chips" do
    it "puts each level list on its level's ring" do
      [3, 5].each { level_list(it) }

      expect(chart.chips.map(&:ring)).to eq([1, 2])
    end

    it "puts chips at the end of the half ring" do
      level_list(1)

      expect(chart.chips.sole.angle).to eq(180.0)
    end

    it "leaves out a level list with no level" do
      placed_list(curriculum: true)

      expect(chart.chips).to be_empty
    end

    it "leaves out a level list the learner can't see" do
      level_list(1, visibility: "private", user: create(:user))

      expect(chart.chips).to be_empty
    end
  end

  describe "#nodes" do
    it "shows a public list" do
      list = placed_list(user: create(:user))

      expect(lists_on_map).to eq([list])
    end

    it "leaves out a level list" do
      level_list(1)

      expect(lists_on_map).to be_empty
    end

    it "leaves out a list the layout has given no angle" do
      placed_list(angle: nil)

      expect(lists_on_map).to be_empty
    end

    it "leaves out another language's list" do
      placed_list(language: "pt")

      expect(lists_on_map).to be_empty
    end

    it "leaves out another learner's private list" do
      source_list(visibility: "private", user: create(:user))

      expect(lists_on_map).to be_empty
    end

    it "shows the learner's own private source" do
      list = source_list(visibility: "private")

      expect(lists_on_map).to eq([list])
    end

    it "leaves out the learner's own private list with no source" do
      placed_list(visibility: "private")

      expect(lists_on_map).to be_empty
    end

    it "shows a private source the learner was let into" do
      list = source_list(visibility: "private", user: create(:user))
      create(:source_reader, source: list.source, user: default_user)

      expect(lists_on_map).to eq([list])
    end

    it "shows a private list the learner has a deck for" do
      list = placed_list(visibility: "private", user: create(:user))
      create(:reading_deck, word_list: list)

      expect(lists_on_map).to eq([list])
    end

    it "leaves out a source with no snippet to read yet" do
      source_list(snippet: [])

      expect(lists_on_map).to be_empty
    end

    it "puts a list on its level's ring" do
      [1, 2].each { level_list(it) }
      placed_list(level: 2)

      expect(chart.nodes.sole.ring).to eq(2)
    end

    it "puts a list past the top level on the last ring" do
      level_list(1)
      placed_list(level: 2)

      expect(chart.nodes.sole.ring).to eq(2)
    end

    it "puts a list with no level on the last ring" do
      level_list(1)
      placed_list

      expect(chart.nodes.sole.ring).to eq(2)
    end

    it "puts every list on the one ring of a language with no levels" do
      placed_list

      expect(chart.nodes.sole.ring).to eq(1)
    end

    it "gives a list its stored angle" do
      placed_list(angle: 42.5)

      expect(chart.nodes.sole.angle).to eq(42.5)
    end

    it "moves lists that share a spot apart" do
      create_list(:word_list, 2, visibility: "public", angle: 90)
        .each { create(:sense_membership, word_list: it) }

      expect(chart.nodes.map(&:angle).map(&:round)).to eq([90, 111])
    end

    it "gives a node on a short ring no more than its share of the ring" do
      (1..4).each { level_list(it) }
      create_list(:word_list, 2, visibility: "public", angle: 90, level: 1)
        .each { create(:sense_membership, word_list: it) }

      expect(chart.nodes.map(&:angle)).to eq([90.0, 150.0])
    end

    it "carries the learner's heat" do
      deck = create(:reading_deck, word_list: placed_list)
      create(:language_card, deck:, correct_streak: 3)

      expect(chart.nodes.sole.heat.percent).to eq(50)
    end
  end

  # The learner's deck over a list on the map.
  def started(word_list = placed_list, **)
    create(:reading_deck, word_list:, **)
  end

  def met_goal(deck)
    count = deck.study_goal
    deck.study_days.create!(studied_on: Date.current, completed_count: count)
  end

  describe "a started node" do
    it "carries the learner's decks over its list" do
      deck = create(:reading_deck, word_list: placed_list)

      expect(chart.nodes.sole.decks).to eq([deck])
    end

    it "carries a source's section decks together" do
      list = source_list
      snippets = [list.snippets.sole, create(:snippet, word_list: list)]
      decks = snippets.map { started(list, snippet: it) }

      expect(chart.nodes.sole.decks).to match_array(decks)
    end

    it "leaves out another learner's deck" do
      create(:reading_deck, word_list: placed_list, user: create(:user))

      expect(chart.nodes.sole).not_to be_started
    end

    it "is unmet while a deck is short of today's goal" do
      create(:reading_deck, word_list: placed_list)

      expect(chart.nodes.sole).to be_unmet
    end

    it "is met once its deck reaches today's goal" do
      met_goal(create(:reading_deck, word_list: placed_list))

      expect(chart.nodes.sole).to be_met
    end

    it "is not unmet while its deck waits for tomorrow" do
      sense = started(round: 2).word_list.senses.sole
      today = { correct_streak: 1, last_correct_at: Time.current }
      create(:skill_score, sense:, **today)

      expect(chart.nodes.sole).not_to be_unmet
    end

    it "marks a started chip too" do
      create(:reading_deck, word_list: level_list(1))

      expect(chart.chips.sole).to be_started
    end
  end

  describe "#start" do
    it "is the node up the center" do
      list = placed_list

      expect(chart.start.word_list).to eq(list)
    end

    it "is the innermost of the nodes up the center" do
      [1, 2].each { level_list(it) }
      lists = [placed_list(level: 2), placed_list(level: 1)]

      expect(chart.start.word_list).to eq(lists.last)
    end

    it "is nothing with no node up the center" do
      placed_list(angle: 40)

      expect(chart.start).to be_nil
    end

    it "is a started node ahead of the node up the center" do
      placed_list
      deck = create(:reading_deck, word_list: placed_list(angle: 40))

      expect(chart.start.word_list).to eq(deck.word_list)
    end

    it "is the innermost started node short of today's goal" do
      [1, 2].each { level_list(it) }
      decks = [2, 1].map { started(placed_list(level: it)) }

      expect(chart.start.word_list).to eq(decks.last.word_list)
    end

    it "is the most recently studied of those on one ring" do
      decks = [1, 2].map { started(last_studied_at: it.days.ago) }

      expect(chart.start.word_list).to eq(decks.first.word_list)
    end

    it "passes over a node whose goal is met for one still short" do
      [1, 2].each { level_list(it) }
      decks = [1, 2].map { started(placed_list(level: it)) }
      met_goal(decks.first)

      expect(chart.start.word_list).to eq(decks.last.word_list)
    end

    it "is the most recently studied node once every goal is met" do
      decks = [2, 1].map { started(last_studied_at: it.days.ago) }
      decks.each { met_goal(it) }

      expect(chart.start.word_list).to eq(decks.last.word_list)
    end

    it "may be a level's chip" do
      create(:reading_deck, word_list: level_list(1))

      expect(chart.start).to eq(chart.chips.sole)
    end
  end

  describe "#links" do
    it "gives each line between two lists on the map" do
      lists = [placed_list, placed_list]
      link(lists)

      expect(chart.links.sole.first(2).map(&:word_list)).to eq(lists)
    end

    it "gives a line's strength" do
      lists = [placed_list, placed_list]
      link(lists)

      expect(chart.links.sole.last).to eq(0.5)
    end

    it "leaves out a line to a list that isn't on the map" do
      lists = [placed_list, placed_list(angle: nil)]
      link(lists)

      expect(chart.links).to be_empty
    end
  end

  describe "#point" do
    it "puts the middle of the one ring's center halfway up" do
      expect(chart.point(1, 90.0)).to eq([50.0, 25.0])
    end

    it "puts a low angle to the left" do
      expect(chart.point(1, 0.0)).to eq([25.0, 50.0])
    end

    it "puts a ring further out with more rings inside it" do
      level_list(1)

      expect(chart.point(2, 90.0)).to eq([50.0, 12.5])
    end
  end

  describe "#radius" do
    it "draws a line at its ring's outer edge" do
      level_list(1)

      expect(chart.radius(1)).to eq(25.0)
    end
  end
end
