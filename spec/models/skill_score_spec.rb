# frozen_string_literal: true

require "rails_helper"

RSpec.describe SkillScore do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:sense) }

  it "accepts only the reading and writing skills" do
    expect(described_class.new)
      .to validate_inclusion_of(:skill).in_array(["reading", "writing"])
  end

  it "starts every counter at zero" do
    expect(described_class.new)
      .to have_attributes(correct_count: 0, correct_streak: 0, view_count: 0)
  end

  it "is unique per user, sense and skill" do
    existing = create(:skill_score)
    duplicate = build(:skill_score, user: existing.user, sense: existing.sense)

    expect(duplicate).not_to be_valid
  end

  it "allows the other skill on the same sense" do
    existing = create(:skill_score)
    writing = build(:skill_score, skill: "writing")
    writing.assign_attributes(user: existing.user, sense: existing.sense)

    expect(writing).to be_valid
  end

  describe "#record_correct!" do
    it "advances every counter" do
      score = create(:skill_score)

      score.record_correct!

      expect(score.reload)
        .to have_attributes(correct_count: 1, correct_streak: 1, view_count: 1)
    end
  end

  describe "#record_miss!" do
    it "resets the streak and counts the view" do
      score = create(:skill_score, correct_count: 2, correct_streak: 2)

      score.record_miss!

      expect(score.reload)
        .to have_attributes(correct_count: 2, correct_streak: 0, view_count: 1)
    end
  end

  describe "#record_view!" do
    it "counts the view alone" do
      score = create(:skill_score, correct_streak: 2)

      score.record_view!

      expect(score.reload)
        .to have_attributes(correct_count: 0, correct_streak: 2, view_count: 1)
    end
  end
end
