# frozen_string_literal: true

require "rails_helper"

RSpec.describe CardSuggestion do
  it { is_expected.to belong_to(:card) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:front) }
  it { is_expected.to validate_presence_of(:back) }
  it { is_expected.to validate_presence_of(:category) }

  it "defaults state to pending" do
    expect(described_class.new.state).to eq("pending")
  end

  it "rejects invalid state values" do
    suggestion = build(:card_suggestion, state: "bogus")

    expect(suggestion).not_to be_valid
  end

  describe ".pending" do
    it "returns only suggestions whose state is pending" do
      pending = create(:card_suggestion, state: "pending")
      create(:card_suggestion, state: "accepted")
      create(:card_suggestion, state: "rejected")

      expect(described_class.pending).to eq([pending])
    end
  end
end
