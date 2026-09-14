# frozen_string_literal: true

require "rails_helper"

RSpec.describe SenseExample do
  it { is_expected.to belong_to(:sense) }

  it { is_expected.to validate_presence_of(:sentence) }

  it "holds a sentence once per sense" do
    example = create(:sense_example, sentence: "我很好。")
    twice = build(:sense_example, sense: example.sense, sentence: "我很好。")

    expect(twice).not_to be_valid
  end
end
