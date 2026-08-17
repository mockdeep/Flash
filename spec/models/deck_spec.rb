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

  describe "#data_set" do
    it "is not required for a flat-card deck" do
      deck = BasicDeck.new(flat_deck_attributes)

      expect(deck.valid?).to be(true)
    end

    it "is required for a language deck" do
      deck = ReadingDeck.new(user: build(:user), study_goal: 1)

      deck.valid?

      expect(deck.errors[:data_set]).to be_present
    end

    it "must be absent for a flat-card deck" do
      deck = BasicDeck.new(
        **flat_deck_attributes, data_set: create(:data_set),
      )

      deck.valid?

      expect(deck.errors[:data_set]).to be_present
    end

    def deck_sharing(existing, user:)
      build(:reading_deck, data_set: existing.data_set, user:)
    end

    # Copies reference the source data_set, so adding the same catalog deck
    # twice would otherwise leave a user with two identical decks.
    it "rejects a second deck over the same data_set for one user" do
      existing = create(:reading_deck)
      deck = deck_sharing(existing, user: existing.user)

      deck.valid?

      expect(deck.errors[:base])
        .to include("This deck is already in your decks")
    end

    it "allows another user a deck over the same data_set" do
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

  describe "#cards_in_category" do
    it "finds cards by their category column" do
      deck = create(:deck)
      card = create(:basic_card, deck:, category: "Math")
      create(:basic_card, deck:, category: "Art")

      expect(deck.cards_in_category("Math")).to contain_exactly(card)
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

  describe "#mandarin?" do
    it "is true when the data_set language is Mandarin" do
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
