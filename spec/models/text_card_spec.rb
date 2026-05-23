# frozen_string_literal: true

require "rails_helper"

RSpec.describe TextCard do
  describe "example pair validation" do
    it "accepts neither example field" do
      card = build(:card, example_front: nil, example_back: nil)

      expect(card).to be_valid
    end

    it "accepts both example fields together" do
      card = build(:card, example_front: "Bonjour", example_back: "Hi")

      expect(card).to be_valid
    end

    it "rejects example_front without example_back" do
      card = build(:card, example_front: "Bonjour", example_back: nil)

      expect(card.tap(&:validate).errors[:example_back]).to be_present
    end

    it "rejects example_back without example_front" do
      card = build(:card, example_front: nil, example_back: "Hello")

      expect(card.tap(&:validate).errors[:example_front]).to be_present
    end

    it "treats blank strings the same as nil" do
      card = build(:card, example_front: "Bonjour", example_back: "  ")

      expect(card).not_to be_valid
    end
  end
end
