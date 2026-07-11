# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingDeck do
  it "builds ReadingCards" do
    expect(described_class.new.card_type).to eq("ReadingCard")
  end
end
