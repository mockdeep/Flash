# frozen_string_literal: true

require "rails_helper"

RSpec.describe SenseDistractor do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:sense) }
  it { is_expected.to belong_to(:distractor_sense).class_name("Sense") }

  def duplicate_of(existing)
    build(
      :sense_distractor,
      user: existing.user,
      sense: existing.sense,
      distractor_sense: existing.distractor_sense,
    )
  end

  it "starts with no misses" do
    expect(described_class.new.miss_count).to eq(0)
  end

  it "is unique per user, sense and distractor sense" do
    existing = create(:sense_distractor)

    expect(duplicate_of(existing)).not_to be_valid
  end
end
