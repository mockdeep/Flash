# frozen_string_literal: true

require "rails_helper"

RSpec.describe Topic do
  it { is_expected.to belong_to(:user).required }
  it { is_expected.to have_many(:decks).dependent(:nullify) }

  it { is_expected.to validate_presence_of(:name) }

  it "validates uniqueness of name scoped to user" do
    create(:topic)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  it "releases its decks when destroyed" do
    topic = create(:topic)
    deck = create(:deck, topic:)

    topic.destroy!

    expect(deck.reload.topic).to be_nil
  end
end
