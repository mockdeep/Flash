# frozen_string_literal: true

RSpec.describe Deck do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:cards).dependent(:delete_all) }

  it do
    create(:deck)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
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

    it "excludes demo decks" do
      deck = create(:deck, :demo)

      expect(described_class.publicly_visible).not_to include(deck)
    end

    it "excludes private decks" do
      deck = create(:deck, visibility: "private")

      expect(described_class.publicly_visible).not_to include(deck)
    end
  end

  describe ".demo_visible" do
    it "includes demo decks" do
      deck = create(:deck, :demo)

      expect(described_class.demo_visible).to include(deck)
    end

    it "excludes public decks" do
      deck = create(:deck, visibility: "public")

      expect(described_class.demo_visible).not_to include(deck)
    end

    it "excludes private decks" do
      deck = create(:deck, visibility: "private")

      expect(described_class.demo_visible).not_to include(deck)
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
