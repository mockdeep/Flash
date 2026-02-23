# frozen_string_literal: true

RSpec.describe DemoController do
  let(:owner) { create(:user) }
  let(:demo_deck) { create(:deck, :demo, user: owner) }

  describe "#show" do
    it "renders the demo page without authentication" do
      get(demo_path)

      expect(response).to have_http_status(:ok)
    end

    it "lists demo decks" do
      demo_deck
      get(demo_path)

      expect(rendered).to have_content(demo_deck.name)
    end

    it "does not list private decks" do
      private_deck = create(:deck, user: owner, visibility: "private")
      get(demo_path)

      expect(rendered).to have_no_content(private_deck.name)
    end

    it "renders empty state when no demo decks exist" do
      get(demo_path)

      expect(rendered).to have_css(
        ".empty-state",
        text: "No demo decks available yet",
      )
    end
  end

  describe "#create" do
    before do
      create(:card, deck: demo_deck, front: "Q", back: "A")
    end

    it "redirects to the study page" do
      post(demo_path, params: { deck_id: demo_deck.id })

      expect(response).to redirect_to(deck_study_path(Deck.last))
    end

    it "sets session demo flag" do
      post(demo_path, params: { deck_id: demo_deck.id })

      follow_redirect!
      expect(rendered).to have_css(".demo-banner")
    end

    it "creates a guest user" do
      action = -> { post(demo_path, params: { deck_id: demo_deck.id }) }

      expect(&action).to change(User, :count).by(1)
    end

    it "assigns the guest role to the new user" do
      post(demo_path, params: { deck_id: demo_deck.id })

      expect(User.last.role).to eq("guest")
    end

    it "allows the guest to access the study page" do
      post(demo_path, params: { deck_id: demo_deck.id })

      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it "cleans up the guest when a real user logs in" do
      post(demo_path, params: { deck_id: demo_deck.id })
      guest = User.last

      login_as(owner)
      expect(User.exists?(guest.id)).to be(false)
    end

    it "handles an already-deleted guest gracefully" do
      post(demo_path, params: { deck_id: demo_deck.id })
      User.last.destroy!

      login_as(owner)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "guest access to study page" do
    it "redirects to sign in without a session" do
      get(deck_study_path(demo_deck))

      expect(response).to redirect_to(new_session_path)
    end
  end
end
