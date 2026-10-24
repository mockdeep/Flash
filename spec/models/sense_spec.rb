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

  describe ".used" do
    it "includes a sense a list holds" do
      sense = create(:sense_membership).sense

      expect(described_class.used).to eq([sense])
    end

    it "includes a sense a snippet's token points at" do
      sense = create(:sense)
      create(:snippet_sentence, tokens: [{ text: "爱", sense_id: sense.id }])

      expect(described_class.used).to eq([sense])
    end

    it "leaves out a sense nothing uses" do
      create(:sense)

      expect(described_class.used).to be_empty
    end
  end

  it "is unique on gloss within an entry" do
    sense = create(:sense, gloss: "flower")

    expect(build(:sense, entry: sense.entry, gloss: "flower")).not_to be_valid
  end

  it "allows a gloss again under another traditional form" do
    sense = create(:sense, gloss: "imagination", traditional: "想像")
    other = build(
      :sense, entry: sense.entry, gloss: "imagination", traditional: "想象"
    )

    expect(other).to be_valid
  end

  it "is unique on gloss within an entry and traditional form" do
    sense = create(:sense, gloss: "imagination", traditional: "想像")
    other = build(
      :sense, entry: sense.entry, gloss: "imagination", traditional: "想像"
    )

    expect(other).not_to be_valid
  end
end
