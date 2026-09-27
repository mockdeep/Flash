# frozen_string_literal: true

RSpec.describe NullTopic do
  describe "#name" do
    it "returns 'Other Decks'" do
      expect(described_class.new(user: default_user).name).to eq("Other Decks")
    end
  end

  describe "#decks" do
    it "includes the user's decks without a topic" do
      deck = create(:deck, user: default_user)

      expect(described_class.new(user: default_user).decks).to include(deck)
    end

    it "excludes the user's decks with a topic" do
      topic = create(:topic, user: default_user)
      deck = create(:deck, user: default_user, topic:)

      expect(described_class.new(user: default_user).decks).not_to include(deck)
    end

    it "excludes other users' decks" do
      deck = create(:deck, user: create(:user))

      expect(described_class.new(user: default_user).decks).not_to include(deck)
    end
  end
end
