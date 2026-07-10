# frozen_string_literal: true

require "rails_helper"

RSpec.describe MusicDataSet do
  it "forbids a language" do
    expect(described_class.new).not_to allow_value("zh").for(:language)
  end

  it "builds music decks" do
    expect(described_class.new.deck_classes).to contain_exactly(MusicDeck)
  end
end
