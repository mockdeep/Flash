# frozen_string_literal: true

RSpec.describe SuggestionsController do
  def own_catalog_deck(**overrides)
    create(:deck, user: default_user, visibility: "public", **overrides)
  end

  def other_catalog_deck
    create(:deck, user: create(:user), visibility: "public")
  end

  def build_pending_suggestion(deck: own_catalog_deck, **overrides)
    card = create(:card, deck:)
    create(:card_suggestion, card:, **overrides)
  end

  def deck_for(suggestion)
    suggestion.card.deck
  end

  describe "#index" do
    it "requires authentication" do
      get(deck_suggestions_path(create(:deck)))

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the suggestions page for the deck owner" do
      deck = own_catalog_deck(name: "Geography")
      login_as(default_user)

      get(deck_suggestions_path(deck))

      expect(rendered).to have_text("Suggestions for Geography")
    end

    it "lists pending suggestions for the deck's cards" do
      suggestion = build_pending_suggestion(front: "Suggested Q")
      login_as(default_user)

      get(deck_suggestions_path(deck_for(suggestion)))

      expect(rendered).to have_text("Suggested Q")
    end

    it "shows the suggester username" do
      user = create(:user, username: "alice")
      suggestion = build_pending_suggestion(user:)
      login_as(default_user)

      get(deck_suggestions_path(deck_for(suggestion)))

      expect(rendered).to have_text("Suggested by alice")
    end

    it "omits accepted suggestions" do
      suggestion =
        build_pending_suggestion(front: "Accepted Q", state: "accepted")
      login_as(default_user)

      get(deck_suggestions_path(deck_for(suggestion)))

      expect(rendered).to have_no_text("Accepted Q")
    end

    it "shows an empty state when there are no pending suggestions" do
      login_as(default_user)

      get(deck_suggestions_path(own_catalog_deck))

      expect(rendered).to have_text("No pending suggestions")
    end

    it "returns not found for another user's deck" do
      login_as(default_user)

      get(deck_suggestions_path(create(:deck, user: create(:user))))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#accept" do
    it "applies the suggested front to the card" do
      suggestion = build_pending_suggestion(front: "Better Q")
      login_as(default_user)

      post(accept_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(CardContent.new(suggestion.card.reload).front).to eq("Better Q")
    end

    it "marks the suggestion accepted" do
      suggestion = build_pending_suggestion
      login_as(default_user)

      post(accept_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(suggestion.reload.state).to eq("accepted")
    end

    it "redirects back to the suggestions page" do
      suggestion = build_pending_suggestion
      login_as(default_user)

      post(accept_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(response)
        .to redirect_to(deck_suggestions_path(deck_for(suggestion)))
    end

    it "sets a success flash" do
      suggestion = build_pending_suggestion
      login_as(default_user)

      post(accept_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(flash[:success]).to eq("Suggestion applied to the card")
    end

    def build_colliding_suggestion(deck)
      create(:card, deck:, front: "Existing")
      target = create(:card, deck:, front: "Target")
      create(:card_suggestion, card: target, front: "Existing")
    end

    it "sets an error flash when the suggestion can't apply cleanly" do
      deck = own_catalog_deck
      suggestion = build_colliding_suggestion(deck)
      login_as(default_user)

      post(accept_deck_suggestion_path(deck, suggestion))

      expect(flash[:error]).to include("Front has already been taken")
    end

    it "ignores already-accepted suggestions" do
      suggestion = build_pending_suggestion(state: "accepted")
      login_as(default_user)

      post(accept_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(response).to have_http_status(:not_found)
    end

    it "rejects accepts from non-owners" do
      suggestion = build_pending_suggestion(deck: other_catalog_deck)
      login_as(default_user)

      post(accept_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#reject" do
    it "marks the suggestion rejected" do
      suggestion = build_pending_suggestion
      login_as(default_user)

      post(reject_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(suggestion.reload.state).to eq("rejected")
    end

    it "does not modify the card" do
      suggestion = build_pending_suggestion(front: "Different")
      original_front = suggestion.card.front
      login_as(default_user)

      post(reject_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(suggestion.card.reload.front).to eq(original_front)
    end

    it "redirects back to the suggestions page" do
      suggestion = build_pending_suggestion
      login_as(default_user)

      post(reject_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(response)
        .to redirect_to(deck_suggestions_path(deck_for(suggestion)))
    end

    it "sets a success flash" do
      suggestion = build_pending_suggestion
      login_as(default_user)

      post(reject_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(flash[:success]).to eq("Suggestion rejected")
    end

    it "rejects from non-owners" do
      suggestion = build_pending_suggestion(deck: other_catalog_deck)
      login_as(default_user)

      post(reject_deck_suggestion_path(deck_for(suggestion), suggestion))

      expect(response).to have_http_status(:not_found)
    end
  end
end
