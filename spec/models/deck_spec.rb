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
end
