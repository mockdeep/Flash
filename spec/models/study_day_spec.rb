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

    it "saves the target's goal on a new row" do
      deck = create(:deck, :with_target)
      create_list(:basic_card, 2, deck:)

      expect(deck.study_days.today.goal).to eq(2)
    end

    it "keeps the goal already saved on today's row" do
      deck = create(:deck, :with_target)
      create_list(:basic_card, 2, deck:)
      deck.study_days.create!(studied_on: Date.current, goal: 5)

      expect(deck.study_days.today.goal).to eq(5)
    end
  end

  describe "#study_goal" do
    it "is the saved goal while the target is active" do
      deck = create(:deck, :with_target)
      study_day = described_class.new(deck:, goal: 5)

      expect(study_day.study_goal).to eq(5)
    end

    it "ignores the saved goal once the target level is finished" do
      deck = create(:deck, :with_target, study_goal: 30)
      deck.update!(level: 2)
      study_day = described_class.new(deck:, goal: 5)

      expect(study_day.study_goal).to eq(30)
    end

    it "falls back to the deck's cards per session" do
      study_day = described_class.new(deck: create(:deck, study_goal: 30))

      expect(study_day.study_goal).to eq(30)
    end
  end

  describe "#record_completion!" do
    it "adds one to the count" do
      study_day = create(:deck).study_days.today

      expect { study_day.record_completion! }
        .to change_record(study_day, :completed_count).from(0).to(1)
    end
  end

  describe "#recalculate!" do
    def recalculated_day
      deck = create(:deck, :with_target)
      create_list(:basic_card, 2, deck:)
      study_day = deck.study_days.create!(
        studied_on: Date.current, goal: 5, completed_count: 3,
      )
      study_day.recalculate!
      study_day
    end

    it "works the goal out again from the target" do
      expect(recalculated_day.goal).to eq(2)
    end

    it "starts a new batch" do
      expect(recalculated_day.completed_count).to eq(0)
    end

    it "clears the goal when the deck has no target" do
      study_day =
        create(:deck).study_days.create!(studied_on: Date.current, goal: 5)

      expect { study_day.recalculate! }
        .to change_record(study_day, :goal).from(5).to(nil)
    end
  end

  describe "#keep_going!" do
    def kept_going_day
      deck = create(:deck, :with_target, target_date: Date.tomorrow)
      create_list(:basic_card, 3, deck:)
      study_day = deck.study_days.create!(
        studied_on: Date.current, goal: 5, completed_count: 3,
      )
      study_day.keep_going!
      study_day
    end

    it "sizes the batch to lower tomorrow's goal by one" do
      expect(kept_going_day.goal).to eq(1)
    end

    it "starts a new batch" do
      expect(kept_going_day.completed_count).to eq(0)
    end

    it "clears the goal when the deck has no target" do
      study_day =
        create(:deck).study_days.create!(studied_on: Date.current, goal: 5)

      expect { study_day.keep_going! }
        .to change_record(study_day, :goal).from(5).to(nil)
    end
  end
end
