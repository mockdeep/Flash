# frozen_string_literal: true

RSpec.describe StudyGoalResetsController do
  def met_goal_deck(**)
    deck = create(:deck, study_goal: 1, **)
    deck.study_days.create!(studied_on: Date.current, completed_count: 1)
    deck
  end

  def yesterday_study_day
    study_days = create(:deck).study_days
    study_days.create!(studied_on: Date.yesterday, completed_count: 5)
  end

  describe "#create" do
    it "resets today's count on the user's decks" do
      login_as(default_user)
      study_day = met_goal_deck.study_days.sole

      expect { post(study_goal_reset_path) }
        .to change_record(study_day, :completed_count).to(0)
    end

    it "leaves earlier days alone" do
      login_as(default_user)
      study_day = yesterday_study_day

      expect { post(study_goal_reset_path) }
        .not_to change_record(study_day, :completed_count)
    end

    it "leaves other users' decks alone" do
      login_as(default_user)
      study_day = met_goal_deck(user: create(:user)).study_days.sole

      expect { post(study_goal_reset_path) }
        .not_to change_record(study_day, :completed_count)
    end

    it "redirects to the first deck in topic order" do
      login_as(default_user)
      met_goal_deck(name: "Alpha")
      deck = met_goal_deck(name: "Zebra", topic: create(:topic))

      post(study_goal_reset_path)

      expect(response).to redirect_to(deck_study_path(deck))
    end

    it "redirects to the decks page when no deck has a goal" do
      login_as(default_user)

      post(study_goal_reset_path)

      expect(response).to redirect_to(decks_path)
    end
  end
end
