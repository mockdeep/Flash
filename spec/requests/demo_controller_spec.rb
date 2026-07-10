# frozen_string_literal: true

RSpec.describe DemoController do
  def demo_deck_with_card
    deck = create(:deck, visibility: "public")
    create(:card, deck:, front: "Q", back: "A")
    deck
  end

  def start_demo(deck: demo_deck_with_card, time_zone: "UTC")
    post(demo_path, params: { deck_id: deck.id, time_zone: })
  end

  describe "#show" do
    it "renders the demo page without authentication" do
      get(demo_path)

      expect(response).to have_http_status(:ok)
    end

    it "lists public decks" do
      deck = create(:deck, visibility: "public")
      get(demo_path)

      expect(rendered).to have_text(deck.name)
    end

    it "does not list private decks" do
      private_deck = create(:deck, visibility: "private")
      get(demo_path)

      expect(rendered).to have_no_text(private_deck.name)
    end

    it "renders empty state when no public decks exist" do
      get(demo_path)

      expect(rendered).to have_css(
        ".empty-state",
        text: "No demo decks available yet",
      )
    end
  end

  describe "#create" do
    it "redirects to the study page" do
      start_demo

      expect(response).to redirect_to(deck_study_path(Deck.last))
    end

    it "sets session demo flag" do
      start_demo

      follow_redirect!
      expect(rendered).to have_css(".demo-banner")
    end

    it "creates a guest user" do
      deck = demo_deck_with_card

      expect { start_demo(deck:) }.to change(User, :count).by(1)
    end

    it "assigns the guest role to the new user" do
      start_demo

      expect(User.last.role).to eq("guest")
    end

    it "stores the submitted time zone on the guest" do
      start_demo(time_zone: "America/New_York")

      expect(User.last.time_zone).to eq("America/New_York")
    end

    it "allows the guest to access the study page" do
      start_demo

      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it "cleans up the guest when a real user logs in" do
      start_demo
      guest = User.last

      login_as(default_user)
      expect(User.exists?(guest.id)).to be(false)
    end

    it "handles an already-deleted guest gracefully" do
      start_demo
      User.last.destroy!

      login_as(default_user)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "guest access to study page" do
    it "redirects to sign in without a session" do
      deck = create(:deck, visibility: "public")
      get(deck_study_path(deck))

      expect(response).to redirect_to(new_session_path)
    end
  end
end
