# frozen_string_literal: true

require "rails_helper"

RSpec.describe StudyDay do
  it { is_expected.to belong_to(:deck) }
  it { is_expected.to validate_presence_of(:deck_id) }
  it { is_expected.to validate_presence_of(:studied_on) }
  it { is_expected.to validate_presence_of(:completed_count) }

  describe ".today" do
    it "creates a row for today when there is none" do
      deck = create(:deck)

      expect(deck.study_days.today.studied_on).to eq(Date.current)
    end

    it "returns the existing row for today" do
      deck = create(:deck)
      study_day = deck.study_days.create!(studied_on: Date.current)

      expect(deck.study_days.today).to eq(study_day)
    end

    it "does not reuse an earlier day's row" do
      deck = create(:deck)
      study_day = deck.study_days.create!(studied_on: Date.yesterday)

      expect(deck.study_days.today).not_to eq(study_day)
    end

    it "uses the current time zone's date" do
      deck = create(:deck)
      travel_to(Time.utc(2026, 5, 30, 5))

      study_day = Time.use_zone("America/Los_Angeles") { deck.study_days.today }

      expect(study_day.studied_on).to eq(Date.new(2026, 5, 29))
    end
  end

  describe "#record_completion!" do
    it "adds one to the count" do
      study_day = create(:deck).study_days.today

      expect { study_day.record_completion! }
        .to change_record(study_day, :completed_count).from(0).to(1)
    end
  end

  describe "#start_batch!" do
    it "counts again from zero" do
      study_days = create(:deck).study_days
      study_day =
        study_days.create!(studied_on: Date.current, completed_count: 5)

      expect { study_day.start_batch! }
        .to change_record(study_day, :completed_count).from(5).to(0)
    end
  end
end
