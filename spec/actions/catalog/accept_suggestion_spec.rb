# frozen_string_literal: true

RSpec.describe Catalog::AcceptSuggestion do
  describe ".call" do
    def build_suggestion(**overrides)
      card = create(:basic_card, front: "Old", back: "Old back")
      create(
        :card_suggestion,
        card:,
        front: "New",
        back: "New back",
        category: "New cat",
        **overrides,
      )
    end

    it "returns success" do
      result = described_class.call(suggestion: build_suggestion)

      expect(result.success?).to be(true)
    end

    it "overwrites the card's front" do
      suggestion = build_suggestion
      described_class.call(suggestion:)

      expect(suggestion.card.reload.front).to eq("New")
    end

    it "overwrites the card's back" do
      suggestion = build_suggestion
      described_class.call(suggestion:)

      expect(suggestion.card.reload.back).to eq("New back")
    end

    it "overwrites the card's category" do
      suggestion = build_suggestion
      described_class.call(suggestion:)

      expect(suggestion.card.reload.category).to eq("New cat")
    end

    it "marks the suggestion accepted" do
      suggestion = build_suggestion
      described_class.call(suggestion:)

      expect(suggestion.reload.state).to eq("accepted")
    end

    def build_colliding_suggestion
      deck = create(:deck)
      create(:basic_card, deck:, front: "Existing")
      target = create(:basic_card, deck:, front: "Target", back: "Original")
      create(
        :card_suggestion,
        card: target,
        front: "Existing",
        back: "New back",
      )
    end

    it "returns failure when the new front collides with another card" do
      result = described_class.call(suggestion: build_colliding_suggestion)

      expect(result.success?).to be(false)
    end

    it "leaves the suggestion pending on failure" do
      suggestion = build_colliding_suggestion
      described_class.call(suggestion:)

      expect(suggestion.reload.state).to eq("pending")
    end

    it "leaves the card unchanged on failure" do
      suggestion = build_colliding_suggestion
      described_class.call(suggestion:)

      expect(suggestion.card.reload.back).to eq("Original")
    end
  end
end
