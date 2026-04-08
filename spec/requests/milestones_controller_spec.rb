# frozen_string_literal: true

RSpec.describe MilestonesController do
  describe "#update" do
    it "updates the deck study goal" do
      login_as(default_user)
      deck = create(:deck)

      expect { patch(deck_milestone_path(deck), params: { study_goal: 25 }) }
        .to change_record(deck, :study_goal).to(25)
    end

    it "redirects to the study page" do
      login_as(default_user)
      deck = create(:deck)

      patch(deck_milestone_path(deck), params: { study_goal: 25 })

      expect(response).to redirect_to(deck_study_path(deck))
    end

    it "prevents updating another user's deck" do
      login_as(default_user)
      other_deck = create(:deck, user: create(:user))

      patch(deck_milestone_path(other_deck), params: { study_goal: 25 })

      expect(response).to have_http_status(:not_found)
    end

    it "redirects to sign in when not authenticated" do
      deck = create(:deck)

      patch(deck_milestone_path(deck), params: { study_goal: 25 })

      expect(response).to redirect_to(new_session_path)
    end
  end
end
