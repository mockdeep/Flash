# frozen_string_literal: true

RSpec.describe Deck do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:cards).dependent(:delete_all) }
  it { is_expected.to have_many(:study_days).dependent(:delete_all) }
  it { is_expected.to have_one(:source).through(:word_list) }
  it { is_expected.to have_many(:snippets).through(:source) }

  def flat_deck_attributes
    {
      name: "T",
      user: build(:user),
      study_goal: 1,
      distractor_pool: "category",
    }
  end

  describe "#word_list" do
    it "is not required for a flat-card deck" do
      deck = BasicDeck.new(flat_deck_attributes)

      expect(deck.valid?).to be(true)
    end

    it "is required for a language deck" do
      deck = ReadingDeck.new(user: build(:user), study_goal: 1)

      deck.valid?

      expect(deck.errors[:word_list]).to be_present
    end

    it "must be absent for a flat-card deck" do
      deck = BasicDeck.new(
        **flat_deck_attributes, word_list: create(:word_list),
      )

      deck.valid?

      expect(deck.errors[:word_list]).to be_present
    end

    def deck_sharing(existing, user:, snippet: existing.snippet)
      build(:reading_deck, word_list: existing.word_list, user:, snippet:)
    end

    # Copies reference the source word_list, so adding the same catalog deck
    # twice would otherwise leave a user with two identical decks.
    it "rejects a second deck over the same word_list for one user" do
      existing = create(:reading_deck)
      deck = deck_sharing(existing, user: existing.user)

      deck.valid?

      expect(deck.errors[:base])
        .to include("This deck is already in your decks")
    end

    it "allows a deck for each snippet of the word_list" do
      existing = create(:reading_deck)
      snippet = create(:snippet, word_list: existing.word_list)

      expect(deck_sharing(existing, user: existing.user, snippet:).valid?)
        .to be(true)
    end

    def snippet_deck
      snippet = create(:snippet)
      create(:reading_deck, word_list: snippet.word_list, snippet:)
    end

    it "rejects a second deck for the same snippet" do
      existing = snippet_deck
      deck = deck_sharing(existing, user: existing.user)

      deck.valid?

      expect(deck.errors[:base])
        .to include("This deck is already in your decks")
    end

    it "rejects a snippet from another word_list" do
      deck = build(:reading_deck, snippet: create(:snippet))

      deck.valid?

      expect(deck.errors[:snippet])
        .to include("must be from the deck's word list")
    end

    it "allows another user a deck over the same word_list" do
      existing = create(:reading_deck)

      expect(deck_sharing(existing, user: create(:user)).valid?).to be(true)
    end
  end

  describe "#name" do
    it "is required for a flat-card deck" do
      deck = build(:deck, name: "")
      deck.valid?

      expect(deck.errors[:name]).to include("can't be blank")
    end

    it "must be unique among the user's decks" do
      existing = create(:deck, name: "Mine")
      deck = build(:deck, name: "Mine", user: existing.user)

      deck.valid?

      expect(deck.errors[:name]).to include("has already been taken")
    end
  end

  describe "#study_goal" do
    it "validates numericality" do
      expect(described_class.new)
        .to validate_numericality_of(:study_goal)
        .only_integer
        .is_greater_than_or_equal_to(1)
    end
  end

  def target_attributes
    { goal_mode: "target", target_round: 1, target_date: Date.current }
  end

  describe "#goal_mode" do
    it "defaults to session" do
      expect(described_class.new.goal_mode).to eq("session")
    end

    it "validates inclusion" do
      expect(described_class.new)
        .to validate_inclusion_of(:goal_mode).in_array(Deck::GOAL_MODES)
    end

    it "clears the target outside target mode" do
      deck = create(:deck, **target_attributes)

      expect { deck.update!(goal_mode: "session") }
        .to change_record(deck, :target_round).to(nil)
    end
  end

  describe "#target_round" do
    it "is required in target mode" do
      expect(described_class.new(goal_mode: "target"))
        .to validate_presence_of(:target_round)
    end

    it "must not be below the deck's round when set" do
      deck = create(:deck, round: 2)

      expect(deck.update(target_attributes)).to be(false)
    end

    it "must be a whole number" do
      deck = create(:deck)

      expect(deck.update(**target_attributes, target_round: 1.5)).to be(false)
    end

    it "lets the deck move on past it" do
      deck = create(:deck, **target_attributes)

      expect(deck.update(round: 2)).to be(true)
    end
  end

  describe "#target_date" do
    it "is required in target mode" do
      expect(described_class.new(goal_mode: "target"))
        .to validate_presence_of(:target_date)
    end

    it "must not be in the past when set" do
      deck = create(:deck)

      expect(deck.update(**target_attributes, target_date: Date.yesterday))
        .to be(false)
    end

    it "lets the deck be saved after the date passes" do
      deck = create(:deck, **target_attributes)
      travel_to(2.days.from_now)

      expect(deck.update(study_goal: 10)).to be(true)
    end
  end

  describe ".ordered" do
    it "returns decks sorted by name" do
      zebra = create(:deck, name: "Zebra")
      alpha = create(:deck, name: "Alpha", user: zebra.user)

      expect(described_class.ordered).to eq([alpha, zebra])
    end

    it "sorts flat and language decks together by name" do
      zebra = create(:deck, name: "Zebra")
      alpha = create(:reading_deck, name: "Alpha", user: zebra.user)

      expect(described_class.ordered).to eq([alpha, zebra])
    end

    # The last section's deck is made first, so deck order can't pass for
    # source order.
    def section_decks_over(whole)
      snippets = create_list(:snippet, 2, word_list: whole.word_list)
      decks =
        snippets.reverse.map do |snippet|
          create(:reading_deck, word_list: whole.word_list, snippet:)
        end
      decks.reverse
    end

    it "puts a source's section decks in source order after the whole" do
      whole = create(:reading_deck)
      sections = section_decks_over(whole)

      expect(described_class.ordered).to eq([whole, *sections])
    end
  end

  describe ".goal_unmet_today" do
    def unmet_decks = described_class.goal_unmet_today

    def studied_deck(completed_count, **)
      deck = create(:deck, study_goal: 2, **)
      deck.study_days.create!(studied_on: Date.current, completed_count:)
      deck
    end

    it "includes decks not studied today" do
      deck = create(:deck)

      expect(unmet_decks).to include(deck)
    end

    it "includes decks under their goal" do
      deck = studied_deck(1)

      expect(unmet_decks).to include(deck)
    end

    it "excludes decks that met their goal" do
      deck = studied_deck(2)

      expect(unmet_decks).not_to include(deck)
    end

    it "ignores rows from other days" do
      deck = create(:deck, study_goal: 1)
      deck.study_days.create!(studied_on: Date.yesterday, completed_count: 1)

      expect(unmet_decks).to include(deck)
    end

    it "excludes decks in no-goal mode" do
      deck = create(:deck, goal_mode: "none")

      expect(unmet_decks).not_to include(deck)
    end

    it "excludes music decks" do
      deck = create(:music_deck)

      expect(unmet_decks).not_to include(deck)
    end

    def target_deck_at_its_goal
      deck = create(:deck, :with_target, study_goal: 50)
      study_days = deck.study_days
      study_days.create!(studied_on: Date.current, completed_count: 2, goal: 2)
      deck
    end

    it "compares against the day's goal while a target is active" do
      deck = target_deck_at_its_goal

      expect(unmet_decks).not_to include(deck)
    end

    it "compares against the daily goal once a target is reached" do
      deck = target_deck_at_its_goal
      deck.update!(round: 2)

      expect(unmet_decks).to include(deck)
    end
  end

  describe ".publicly_visible" do
    it "includes public decks" do
      deck = create(:deck, visibility: "public")

      expect(described_class.publicly_visible).to include(deck)
    end

    it "excludes private decks" do
      deck = create(:deck, visibility: "private")

      expect(described_class.publicly_visible).not_to include(deck)
    end
  end

  describe ".recently_studied" do
    it "orders studied decks most recent first" do
      old = create(:deck, last_studied_at: 2.days.ago)
      new = create(:deck, last_studied_at: 1.hour.ago)

      expect(described_class.recently_studied).to eq([new, old])
    end

    it "excludes decks never studied" do
      deck = create(:deck, last_studied_at: nil)

      expect(described_class.recently_studied).not_to include(deck)
    end
  end

  def round_two_deck
    deck = create(:deck, round: 2)
    create(:basic_card, deck:, correct_streak: 2)
    create(:basic_card, deck:, correct_streak: 1)
    deck
  end

  describe ".with_progress" do
    it "selects each deck's card and done counts alongside its columns" do
      loaded = described_class.with_progress.find(round_two_deck.id)

      expect(loaded.attributes)
        .to include("cards_count" => 2, "done_count" => 1)
    end

    def progress_of(deck)
      described_class.with_progress.find(deck.id).attributes
    end

    # One entry below the round, then one at it, in list order.
    def language_deck
      deck = create(:reading_deck, round: 1)
      create(:language_card, deck:)
      create(:language_card, :done, deck:, back: "he; him")
      deck
    end

    it "counts a language deck's entries and those at the round" do
      expect(progress_of(language_deck))
        .to include("cards_count" => 2, "done_count" => 1)
    end

    # A deck over a snippet that uses only the given card's word.
    def snippet_deck_using(card)
      snippet = create(:snippet, word_list: card.deck.word_list)
      sense_id = Integer(card.id.split("-").first)
      create(:snippet_sentence, snippet:, tokens: [{ "sense_id" => sense_id }])
      create(:reading_deck, word_list: snippet.word_list, snippet:)
    end

    it "counts only the entries a snippet deck's snippet uses" do
      snippet_deck = snippet_deck_using(language_deck.cards_in_order.last)

      expect(progress_of(snippet_deck))
        .to include("cards_count" => 1, "done_count" => 1)
    end

    def guest_deck_over(source)
      guest = create(:user, :guest)
      create(:reading_deck, word_list: source.word_list, user: guest)
    end

    it "stops a guest's language deck at the limit" do
      stub_const("Deck::GUEST_CARD_LIMIT", 1)
      deck = guest_deck_over(language_deck)

      expect(progress_of(deck))
        .to include("cards_count" => 1, "done_count" => 0)
    end
  end

  describe "#card_limit" do
    it "caps a guest's deck" do
      deck = build(:deck, user: build(:user, :guest))

      expect(deck.card_limit).to eq(described_class::GUEST_CARD_LIMIT)
    end

    it "leaves a user's deck uncapped" do
      expect(build(:deck).card_limit).to be_nil
    end
  end

  describe "#cards_count" do
    it "counts the cards when none were selected" do
      expect(round_two_deck.cards_count).to eq(2)
    end
  end

  describe "#done_count" do
    it "counts cards at or above the round when none were selected" do
      expect(round_two_deck.done_count).to eq(1)
    end

    it "shares one query with cards_count and all_done?" do
      deck = round_two_deck.tap(&:cards_count)

      expect { deck.done_count && deck.all_done? }.not_to make_database_queries
    end

    it "counts again once the round changes" do
      deck = round_two_deck.tap(&:done_count)
      deck.round = 3

      expect(deck.done_count).to eq(0)
    end
  end

  describe "#reload" do
    it "forgets the counts" do
      deck = create(:deck, round: 1).tap(&:done_count)
      create(:basic_card, :done, deck:)

      expect(deck.reload.done_count).to eq(1)
    end
  end

  describe "#remaining_count" do
    it "is the cards still below the round" do
      loaded = described_class.with_progress.find(round_two_deck.id)

      expect(loaded.remaining_count).to eq(1)
    end
  end

  describe "#generates_distractors?" do
    it "is true when the pool is category" do
      deck = create(:deck, distractor_pool: "category")

      expect(deck.generates_distractors?).to be(true)
    end

    it "is false when the pool is preset" do
      deck = create(:deck, distractor_pool: "preset")

      expect(deck.generates_distractors?).to be(false)
    end
  end

  describe "#name_translation" do
    it "is the translation of its source's title" do
      deck = create(:reading_deck)
      create(:source, word_list: deck.word_list, title_translation: "Spring")

      expect(deck.name_translation).to eq("Spring")
    end

    it "is nil on a deck with no source" do
      deck = create(:deck)

      expect(deck.name_translation).to be_nil
    end
  end

  describe "#finished_snippets" do
    it "leaves out a snippet not yet finished" do
      deck = create(:reading_deck)
      finished = create(:snippet, :finished, word_list: deck.word_list)
      create(:snippet, word_list: deck.word_list)

      expect(deck.finished_snippets).to eq([finished])
    end

    it "is a snippet deck's own snippet" do
      own = create(:snippet, :finished)
      create(:snippet, :finished, word_list: own.word_list)
      deck = create(:reading_deck, word_list: own.word_list, snippet: own)

      expect(deck.finished_snippets).to eq([own])
    end
  end

  describe "#shares_texts?" do
    it "is true with a finished snippet others may read" do
      deck = create(:reading_deck)
      word_list = deck.word_list
      create(:source, word_list:, license: "public_domain")
      create(:snippet, :finished, word_list:)

      expect(deck.shares_texts?).to be(true)
    end

    it "is false when no finished snippet may be shared" do
      deck = create(:reading_deck)
      create(:snippet, :finished, word_list: deck.word_list)

      expect(deck.shares_texts?).to be(false)
    end
  end

  describe "#card" do
    it "finds the deck's card by id" do
      card = create(:basic_card)

      expect(card.deck.card(card.id)).to eq(card)
    end

    it "raises for a card in another deck" do
      card = create(:basic_card)

      expect { create(:deck).card(card.id) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#study_pool" do
    it "takes the first cards below the round, in deck order" do
      deck = create(:deck, round: 1)
      create(:basic_card, :done, deck:)
      cards = create_list(:basic_card, 3, deck:)

      expect(deck.study_pool(limit: 2)).to eq(cards.first(2))
    end
  end

  describe "#all_done?" do
    it "is true when every card has reached the round" do
      deck = create(:deck, round: 2)
      create(:basic_card, deck:, correct_streak: 2)

      expect(deck.all_done?).to be(true)
    end

    it "is false while a card sits below the round" do
      deck = create(:deck, round: 2)
      create(:basic_card, deck:, correct_streak: 1)

      expect(deck.all_done?).to be(false)
    end
  end

  describe "#catch_up_round!" do
    it "moves on to the round after the lowest streak when all are done" do
      deck = create(:deck, round: 1)
      create(:basic_card, deck:, correct_streak: 2)
      create(:basic_card, deck:, correct_streak: 3)
      deck.catch_up_round!

      expect(deck.reload.round).to eq(3)
    end

    it "keeps the round while a card sits below it" do
      deck = create(:deck, round: 2)
      create(:basic_card, deck:, correct_streak: 1)
      create(:basic_card, deck:, correct_streak: 3)
      deck.catch_up_round!

      expect(deck.reload.round).to eq(2)
    end

    it "keeps the round of a deck without cards" do
      deck = create(:deck, round: 2)
      deck.catch_up_round!

      expect(deck.reload.round).to eq(2)
    end
  end

  describe "#not_done_count" do
    it "counts the cards whose streak is below the given round" do
      deck = create(:deck)
      create(:basic_card, deck:, correct_streak: 1)
      create(:basic_card, deck:, correct_streak: 2)

      expect(deck.not_done_count(2)).to eq(1)
    end
  end

  describe "#no_goal?" do
    it "is true in no-goal mode" do
      expect(described_class.new(goal_mode: "none").no_goal?).to be(true)
    end

    it "is false with a daily goal" do
      expect(described_class.new.no_goal?).to be(false)
    end
  end

  describe "#target_active?" do
    it "is false without a target" do
      expect(described_class.new.target_active?).to be(false)
    end

    it "is true while the target round is unfinished" do
      deck = described_class.new(goal_mode: "target", round: 2, target_round: 2)

      expect(deck.target_active?).to be(true)
    end

    it "is false once the deck has passed the target round" do
      deck = described_class.new(goal_mode: "target", round: 3, target_round: 2)

      expect(deck.target_active?).to be(false)
    end
  end

  describe "#target_missed?" do
    def target_deck(round:, target_date:)
      described_class.new(
        goal_mode: "target", round:, target_round: 2, target_date:,
      )
    end

    it "is true once the date passes with the round unfinished" do
      deck = target_deck(round: 2, target_date: Date.yesterday)

      expect(deck.target_missed?).to be(true)
    end

    it "is false on the target date itself" do
      deck = target_deck(round: 2, target_date: Date.current)

      expect(deck.target_missed?).to be(false)
    end

    it "is false when the target round was finished" do
      deck = target_deck(round: 3, target_date: Date.yesterday)

      expect(deck.target_missed?).to be(false)
    end

    it "is false without a target" do
      expect(described_class.new.target_missed?).to be(false)
    end
  end

  describe "#target_reached?" do
    it "is true once the deck has passed the target round" do
      deck = described_class.new(goal_mode: "target", round: 3, target_round: 2)

      expect(deck.target_reached?).to be(true)
    end

    it "is false while the target round is unfinished" do
      deck = described_class.new(goal_mode: "target", round: 2, target_round: 2)

      expect(deck.target_reached?).to be(false)
    end

    it "is false without a target" do
      expect(described_class.new.target_reached?).to be(false)
    end
  end

  describe "#target_goal" do
    def target_deck(target_date:)
      deck = create(:deck, :with_target, target_round: 2, target_date:)
      create_list(:basic_card, 3, deck:, correct_streak: 0)
      create(:basic_card, deck:, correct_streak: 1)
      deck
    end

    it "is nil without an active target" do
      expect(create(:deck).target_goal).to be_nil
    end

    it "spreads the work left over the days left, including today" do
      # 3 cards left at round 1, plus 4 at round 2, over 2 days.
      deck = target_deck(target_date: Date.tomorrow)

      expect(deck.target_goal).to eq(4)
    end

    it "puts all the work left on the target date itself" do
      deck = target_deck(target_date: Date.current)

      expect(deck.target_goal).to eq(7)
    end

    it "puts all the work left on today once the date has passed" do
      deck = target_deck(target_date: Date.current)
      travel_to(3.days.from_now)

      expect(deck.target_goal).to eq(7)
    end
  end

  describe "#next_target_goal" do
    def target_deck(target_date:)
      deck = create(:deck, :with_target, target_round: 2, target_date:)
      create_list(:basic_card, 3, deck:, correct_streak: 0)
      create(:basic_card, deck:, correct_streak: 1)
      deck
    end

    it "is nil without an active target" do
      expect(create(:deck).next_target_goal).to be_nil
    end

    it "spreads the work left over the days after today" do
      # 3 cards left at round 1, plus 4 at round 2, over 2 days.
      deck = target_deck(target_date: 2.days.from_now.to_date)

      expect(deck.next_target_goal).to eq(4)
    end

    it "is nil on the target date itself" do
      deck = target_deck(target_date: Date.current)

      expect(deck.next_target_goal).to be_nil
    end

    it "is nil once the date has passed" do
      deck = target_deck(target_date: Date.current)
      travel_to(3.days.from_now)

      expect(deck.next_target_goal).to be_nil
    end
  end

  describe "#cards_to_lower_goal" do
    def target_deck(target_date:)
      deck = create(:deck, :with_target, target_round: 2, target_date:)
      create_list(:basic_card, 3, deck:, correct_streak: 0)
      create(:basic_card, deck:, correct_streak: 1)
      deck
    end

    it "is nil without an active target" do
      expect(create(:deck).cards_to_lower_goal).to be_nil
    end

    it "is a card for each day after today" do
      # 7 left over 4 days is 2 a day; 4 more brings it to 1 a day.
      deck = target_deck(target_date: 4.days.from_now.to_date)

      expect(deck.cards_to_lower_goal).to eq(4)
    end

    it "is all the work left once tomorrow's goal is one card" do
      deck = target_deck(target_date: 10.days.from_now.to_date)

      expect(deck.cards_to_lower_goal).to eq(7)
    end

    it "is all the work left on the target date itself" do
      deck = target_deck(target_date: Date.current)

      expect(deck.cards_to_lower_goal).to eq(7)
    end
  end

  describe "#backs" do
    it "lists every card's back" do
      deck = create(:deck)
      create(:basic_card, deck:, back: "Paris")
      create(:basic_card, deck:, back: "Rome")

      expect(deck.backs).to contain_exactly("Paris", "Rome")
    end

    it "leaves out the given card" do
      deck = create(:deck)
      create(:basic_card, deck:, back: "Paris")
      excluded = create(:basic_card, deck:, back: "Rome")

      expect(deck.backs(except: excluded)).to eq(["Paris"])
    end

    it "narrows to the cards filed under a category" do
      deck = create(:deck)
      create(:basic_card, deck:, back: "2", category: "Math")
      create(:basic_card, deck:, back: "Blue", category: "Art")

      expect(deck.backs(category: "Math")).to eq(["2"])
    end
  end

  describe "#cards_in_order" do
    it "lists the cards in deck order" do
      deck = create(:deck)
      first = create(:basic_card, deck:)
      second = create(:basic_card, deck:)

      expect(deck.cards_in_order).to eq([first, second])
    end

    it "stops at the limit" do
      deck = create(:deck)
      first = create(:basic_card, deck:)
      create(:basic_card, deck:)

      expect(deck.cards_in_order(limit: 1)).to eq([first])
    end
  end

  describe "#reading_pairs" do
    it "reads sibling (front, reading) pairs from the card columns" do
      deck = create(:deck)
      create(:basic_card, deck:, front: "两", reading: "liǎng")
      excluded = create(:basic_card, deck:, front: "三", reading: "sān")

      expect(deck.reading_pairs(except: excluded))
        .to contain_exactly(["两", "liǎng"])
    end
  end

  describe "#readings?" do
    it "is true when a card column holds a reading" do
      deck = create(:deck)
      create(:basic_card, deck:, reading: "liǎng")

      expect(deck.readings?).to be(true)
    end

    it "is false when every card's reading is blank" do
      deck = create(:deck)
      create(:basic_card, deck:, reading: nil)
      create(:basic_card, deck:, reading: "")

      expect(deck.readings?).to be(false)
    end
  end

  describe "#mandarin?" do
    it "is true when the word_list language is Mandarin" do
      deck = create(:reading_deck, language: "zh")

      expect(deck.mandarin?).to be(true)
    end

    it "is false when the language is not Mandarin" do
      deck = create(:reading_deck, language: "es")

      expect(deck.mandarin?).to be(false)
    end

    it "is false for a basic deck" do
      deck = create(:deck)

      expect(deck.mandarin?).to be(false)
    end
  end

  describe "#hanzi_chars" do
    it "collects the distinct Han characters across entries" do
      deck = create(:reading_deck)
      create(:language_card, deck:, front: "你好", back: "hello")
      create(:language_card, deck:, front: "好吗", back: "well?")

      expect(deck.hanzi_chars.chars).to contain_exactly("你", "好", "吗")
    end

    it "is empty when no item contains Han characters" do
      deck = create(:reading_deck, language: "es")
      create(:language_card, deck:, front: "hola", back: "hello")

      expect(deck.hanzi_chars).to eq("")
    end
  end

  describe "#publicly_visible?" do
    it "is true when visibility is public" do
      deck = create(:deck, visibility: "public")

      expect(deck.publicly_visible?).to be(true)
    end

    it "is false when visibility is private" do
      deck = create(:deck, visibility: "private")

      expect(deck.publicly_visible?).to be(false)
    end
  end

  describe "#shared?" do
    it "is false when share_token is nil" do
      deck = create(:deck, share_token: nil)

      expect(deck.shared?).to be(false)
    end

    it "is true when share_token is present" do
      deck = create(:deck, share_token: "abc123")

      expect(deck.shared?).to be(true)
    end
  end

  describe "#generate_share_token!" do
    it "sets a non-blank share_token" do
      deck = create(:deck, share_token: nil)

      deck.generate_share_token!

      expect(deck.share_token).to be_present
    end

    it "generates a different token each call" do
      deck = create(:deck, share_token: nil)

      deck.generate_share_token!
      first_token = deck.share_token
      deck.generate_share_token!

      expect(deck.share_token).not_to eq(first_token)
    end
  end

  describe "#revoke_share_token!" do
    it "clears the share_token" do
      deck = create(:deck, share_token: "abc123")

      deck.revoke_share_token!

      expect(deck.share_token).to be_nil
    end
  end
end
