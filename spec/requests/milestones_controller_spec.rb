# frozen_string_literal: true

RSpec.describe MilestonesController do
  def update_milestone(deck, **params)
    patch(deck_milestone_path(deck), params:)
  end

  def target_deck(*traits)
    deck = create(:deck, *traits)
    create_list(:basic_card, 2, deck:)
    deck
  end

  def target_params
    target = { goal_mode: "target", target_level: 1, target_date: Date.current }
    { deck: target }
  end

  describe "#update" do
    it "updates the deck study goal" do
      login_as(default_user)
      deck = create(:deck)

      expect { update_milestone(deck, deck: { study_goal: 25 }) }
        .to change_record(deck, :study_goal).to(25)
    end

    it "redirects to the study page" do
      login_as(default_user)
      deck = create(:deck)

      update_milestone(deck, deck: { study_goal: 25 })

      expect(response).to redirect_to(deck_study_path(deck))
    end

    it "sets the deck's target" do
      login_as(default_user)
      deck = target_deck

      expect { update_milestone(deck, **target_params) }
        .to change_record(deck, :target_level).to(1)
    end

    it "saves today's goal from a new target" do
      login_as(default_user)
      deck = target_deck

      update_milestone(deck, **target_params)

      expect(deck.study_days.sole.goal).to eq(2)
    end

    it "starts a new batch when the target changes" do
      login_as(default_user)
      deck = target_deck
      deck.study_days.create!(studied_on: Date.current, completed_count: 3)

      update_milestone(deck, **target_params)

      expect(deck.study_days.sole.completed_count).to eq(0)
    end

    it "clears today's goal when switching to a daily goal" do
      login_as(default_user)
      deck = create(:deck, :with_target)
      deck.study_days.create!(studied_on: Date.current, goal: 5)

      update_milestone(deck, deck: { goal_mode: "session" })

      expect(deck.study_days.sole.goal).to be_nil
    end

    it "recalculates on request" do
      login_as(default_user)
      deck = target_deck(:with_target)
      deck.study_days.create!(studied_on: Date.current, goal: 5)

      update_milestone(deck, **target_params, recalculate: "Recalculate")

      expect(deck.study_days.sole.goal).to eq(2)
    end

    it "leaves the batch alone when the target is unchanged" do
      login_as(default_user)
      deck = create(:deck)
      deck.study_days.create!(studied_on: Date.current, completed_count: 3)

      update_milestone(deck, deck: { study_goal: 25 })

      expect(deck.study_days.sole.completed_count).to eq(3)
    end

    it "prevents updating another user's deck" do
      login_as(default_user)
      other_deck = create(:deck, user: create(:user))

      update_milestone(other_deck, deck: { study_goal: 25 })

      expect(response).to have_http_status(:not_found)
    end

    it "redirects to sign in when not authenticated" do
      deck = create(:deck)

      update_milestone(deck, deck: { study_goal: 25 })

      expect(response).to redirect_to(new_session_path)
    end
  end
end
