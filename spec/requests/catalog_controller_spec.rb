# frozen_string_literal: true

RSpec.describe CatalogController do
  def public_deck(**attrs)
    owner = create(:user)
    create(:deck, user: owner, visibility: "public", **attrs)
  end

  describe "#index" do
    it "renders without authentication" do
      get(catalog_index_path)

      expect(response).to have_http_status(:ok)
    end

    it "shows public decks" do
      public_deck(name: "Public Deck")

      get(catalog_index_path)

      expect(rendered).to have_content("Public Deck")
    end

    it "does not show private decks" do
      owner = create(:user)
      create(:deck, user: owner, name: "Secret", visibility: "private")

      get(catalog_index_path)

      expect(rendered).to have_no_content("Secret")
    end

    it "shows card count" do
      deck = public_deck
      create(:card, deck:)

      get(catalog_index_path)

      expect(rendered).to have_content("1")
    end

    it "shows empty state when no public decks" do
      get(catalog_index_path)

      expect(rendered).to have_content("No Public Decks Yet")
    end
  end

  describe "#show" do
    it "renders without authentication" do
      deck = public_deck

      get(catalog_path(deck))

      expect(response).to have_http_status(:ok)
    end

    it "shows deck name" do
      deck = public_deck(name: "Preview Deck")

      get(catalog_path(deck))

      expect(rendered).to have_content("Preview Deck")
    end

    it "shows card front in preview" do
      deck = public_deck
      create(:card, deck:, front: "Question 1", back: "Answer 1")

      get(catalog_path(deck))

      expect(rendered).to have_content("Question 1")
    end

    it "shows card back in preview" do
      deck = public_deck
      create(:card, deck:, front: "Question 1", back: "Answer 1")

      get(catalog_path(deck))

      expect(rendered).to have_content("Answer 1")
    end

    it "shows empty message when deck has no cards" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_content("This deck has no cards yet.")
    end

    it "shows card count" do
      deck = public_deck
      create(:card, deck:)

      get(catalog_path(deck))

      expect(rendered).to have_content("1 cards")
    end

    it "shows deck owner" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_content("by #{deck.user.username}")
    end

    it "limits preview to 5 cards" do
      deck = public_deck
      6.times { |i| create(:card, deck:, front: "Q#{i}", back: "A#{i}") }

      get(catalog_path(deck))

      expect(rendered).to have_content("and 1 more cards...")
    end

    it "shows login prompt for unauthenticated visitors" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_content("Log in to Add Deck")
    end

    it "shows copy button for authenticated users" do
      deck = public_deck
      login_as(default_user)

      get(catalog_path(deck))

      expect(rendered).to have_content("Add to My Decks")
    end

    it "returns not found for private decks" do
      owner = create(:user)
      deck = create(:deck, user: owner, visibility: "private")

      get(catalog_path(deck))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#copy" do
    it "requires authentication" do
      deck = public_deck

      post(copy_catalog_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "copies the deck and redirects to decks index" do
      deck = public_deck
      create(:card, deck:, front: "Q", back: "A")
      login_as(default_user)

      post(copy_catalog_path(deck))

      expect(response).to redirect_to(decks_path)
    end

    it "sets success flash message" do
      deck = public_deck
      login_as(default_user)

      post(copy_catalog_path(deck))

      expect(flash[:success]).to eq("Deck copied successfully")
    end

    it "creates a new deck for the current user" do
      deck = public_deck
      login_as(default_user)

      expect { post(copy_catalog_path(deck)) }
        .to change { default_user.decks.count }.by(1)
    end

    it "shows error when user already has deck with that name" do
      deck = public_deck(name: "Existing")
      create(:deck, user: default_user, name: "Existing")
      login_as(default_user)

      post(copy_catalog_path(deck))

      expect(rendered).to have_content("Name has already been taken")
    end
  end
end
