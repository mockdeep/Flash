# frozen_string_literal: true

RSpec.describe Deck do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:cards).dependent(:delete_all) }

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

    def deck_sharing(existing, user:)
      build(:reading_deck, word_list: existing.word_list, user:)
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

  def level_two_deck
    deck = create(:deck, level: 2)
    create(:basic_card, deck:, correct_streak: 2)
    create(:basic_card, deck:, correct_streak: 1)
    deck
  end

  describe ".with_progress" do
    it "selects each deck's card and done counts alongside its columns" do
      loaded = described_class.with_progress.find(level_two_deck.id)

      expect(loaded.attributes)
        .to include("cards_count" => 2, "done_count" => 1)
    end

    def progress_of(deck)
      described_class.with_progress.find(deck.id).attributes
    end

    # One entry below the level, then one at it, in list order.
    def language_deck(user: default_user)
      deck = create(:reading_deck, level: 1, user:)
      create(:reading_card, deck:)
      create(:reading_card, :done, deck:, back: "he; him")
      deck
    end

    it "counts a language deck's entries and those at the level" do
      expect(progress_of(language_deck))
        .to include("cards_count" => 2, "done_count" => 1)
    end

    it "stops a guest's language deck at the limit" do
      stub_const("Deck::GUEST_CARD_LIMIT", 1)
      deck = language_deck(user: create(:user, :guest))

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
      expect(level_two_deck.cards_count).to eq(2)
    end
  end

  describe "#done_count" do
    it "counts cards at or above the level when none were selected" do
      expect(level_two_deck.done_count).to eq(1)
    end
  end

  describe "#remaining_count" do
    it "is the cards still below the level" do
      loaded = described_class.with_progress.find(level_two_deck.id)

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
    it "takes the first cards below the level, in deck order" do
      deck = create(:deck, level: 1)
      create(:basic_card, :done, deck:)
      cards = create_list(:basic_card, 3, deck:)

      expect(deck.study_pool(limit: 2)).to eq(cards.first(2))
    end
  end

  describe "#all_done?" do
    it "is true when every card has reached the level" do
      deck = create(:deck, level: 2)
      create(:basic_card, deck:, correct_streak: 2)

      expect(deck.all_done?).to be(true)
    end

    it "is false while a card sits below the level" do
      deck = create(:deck, level: 2)
      create(:basic_card, deck:, correct_streak: 1)

      expect(deck.all_done?).to be(false)
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
    it "collects the distinct Han characters across items" do
      deck = create(:reading_deck)
      create(:reading_card, deck:, front: "你好", back: "hello")
      create(:reading_card, deck:, front: "好吗", back: "well?")

      expect(deck.hanzi_chars.chars).to contain_exactly("你", "好", "吗")
    end

    it "is empty when no item contains Han characters" do
      deck = create(:reading_deck, language: "es")
      create(:reading_card, deck:, front: "hola", back: "hello")

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
