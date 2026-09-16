# frozen_string_literal: true

require "rails_helper"

RSpec.describe Sense do
  it { is_expected.to belong_to(:entry) }
  it { is_expected.to have_many(:sense_memberships).dependent(:destroy) }
  it { is_expected.to have_many(:word_lists).through(:sense_memberships) }
  it { is_expected.to have_many(:sense_examples).dependent(:destroy) }
  it { is_expected.to have_many(:sense_distractors).dependent(:delete_all) }
  it { is_expected.to have_many(:skill_scores).dependent(:delete_all) }

  it { is_expected.to validate_presence_of(:gloss) }

  it "is unique on gloss within an entry" do
    sense = create(:sense, gloss: "flower")

    expect(build(:sense, entry: sense.entry, gloss: "flower")).not_to be_valid
  end
end
