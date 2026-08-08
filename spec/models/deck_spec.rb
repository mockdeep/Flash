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
  end

  describe "#name" do
    it "surfaces the data_set's name errors on create" do
      deck = build(:deck, name: "")
      deck.valid?

      expect(deck.errors[:name]).to include("can't be blank")
    end

    it "reads a flat deck's name from its own column" do
      deck = create(:deck, name: "Mine")
      deck.data_set.update!(name: "Other")

      expect(deck.reload.name).to eq("Mine")
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

  describe "#user" do
    it "reads the deck's own user, not the data_set's" do
      deck = create(:deck)
      deck.data_set.update!(user: create(:user))

      expect(deck.reload.user_id).not_to eq(deck.data_set.user_id)
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

  describe "#type_allowed_by_data_set" do
    it "rejects a deck class the data_set can't build" do
      deck = build(:deck, data_set: create(:language_data_set))

      expect(deck).not_to be_valid
    end

    it "accepts a deck class the data_set can build" do
      deck = build(:reading_deck)

      expect(deck).to be_valid
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

  describe "direction" do
    it "anchors the Front side by default" do
      expect(described_class.new.anchor_side).to eq("Front")
    end

    it "anchors on the item_id pairing column by default" do
      expect(described_class.new.anchor_pairing_column).to eq(:item_id)
    end
  end

  describe "#reversible?" do
    it "is false for a basic deck" do
      expect(create(:deck).reversible?).to be(false)
    end

    it "is true for a reading deck" do
      expect(create(:reading_deck).reversible?).to be(true)
    end

    it "is false for a writing deck" do
      reading = create(:reading_deck)
      create(:reading_card, deck: reading)
      writing = Decks::CreateReverse.call(source: reading).record

      expect(writing.reversible?).to be(false)
    end
  end

  describe "#reverse_present?" do
    it "is false when the deck has no data_set" do
      expect(described_class.new.reverse_present?).to be(false)
    end

    it "is false when no reverse deck shares the data_set" do
      deck = create(:reading_deck)
      create(:reading_card, deck:)

      expect(deck.reverse_present?).to be(false)
    end

    it "is true when a reverse deck shares the data_set" do
      deck = create(:reading_deck)
      create(:reading_card, deck:)
      Decks::CreateReverse.call(source: deck)

      expect(deck.reload.reverse_present?).to be(true)
    end
  end
end
