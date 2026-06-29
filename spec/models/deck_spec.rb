# frozen_string_literal: true

RSpec.describe Deck do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:data_set) }
  it { is_expected.to have_many(:cards).dependent(:delete_all) }

  describe "#name" do
    it "borrows the data_set's name" do
      deck = create(:deck, name: "HSK 1")

      expect(deck.name).to eq("HSK 1")
    end

    it "surfaces the data_set's name errors on create" do
      deck = build(:deck, name: "")
      deck.valid?

      expect(deck.errors[:name]).to include("can't be blank")
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
    it "is false for the base deck" do
      expect(described_class.new.reversible?).to be(false)
    end

    it "is true for a text deck" do
      expect(create(:deck).reversible?).to be(true)
    end
  end

  describe "#reverse_present?" do
    it "is false when the deck has no data_set" do
      expect(described_class.new.reverse_present?).to be(false)
    end

    it "is false when no reverse deck shares the data_set" do
      deck = create(:deck)
      create(:card, deck:)

      expect(deck.reverse_present?).to be(false)
    end

    it "is true when a reverse deck shares the data_set" do
      deck = create(:deck)
      create(:card, deck:)
      Decks::CreateReverse.call(source: deck)

      expect(deck.reload.reverse_present?).to be(true)
    end
  end
end
