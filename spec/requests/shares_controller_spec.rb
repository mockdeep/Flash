# frozen_string_literal: true

RSpec.describe SharesController do
  def shared_deck(**attrs)
    owner = create(:user)
    deck = create(:deck, user: owner, **attrs)
    deck.generate_share_token!
    deck
  end

  describe "#show" do
    it "renders without authentication" do
      deck = shared_deck

      get(shared_deck_path(deck.share_token))

      expect(response).to have_http_status(:ok)
    end

    it "shows deck name" do
      deck = shared_deck(name: "Shared Deck")

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("Shared Deck")
    end

    it "shows card front in preview" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Question 1", back: "Answer 1")

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("Question 1")
    end

    it "shows card back in preview" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Question 1", back: "Answer 1")

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("Answer 1")
    end

    it "shows empty message when deck has no cards" do
      deck = shared_deck

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("This deck has no cards yet.")
    end

    it "shows card count" do
      deck = shared_deck
      create(:basic_card, deck:)

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("1 cards")
    end

    it "attributes the deck to the owner" do
      deck = shared_deck

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("shared by #{deck.user.username}")
    end

    it "shows a supporter badge when the owner is a subscriber" do
      deck = shared_deck
      create(:subscription, user: deck.user)

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_css(".supporter-badge")
    end

    it "does not show a supporter badge when the owner is not a subscriber" do
      deck = shared_deck

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_no_css(".supporter-badge")
    end

    it "shows a music badge for music decks" do
      owner = create(:user)
      deck = create(:music_deck, user: owner)
      deck.generate_share_token!

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_css("[title='Microphone required']")
    end

    it "does not show a music badge for text decks" do
      deck = shared_deck

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_no_css("[title='Microphone required']")
    end

    it "limits preview to 5 cards" do
      deck = shared_deck
      6.times { |i| create(:basic_card, deck:, front: "Q#{i}", back: "A#{i}") }

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("and 1 more cards...")
    end

    it "shows try button for unauthenticated visitors" do
      deck = shared_deck

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("Try This Deck")
    end

    it "shows copy button for authenticated users" do
      deck = shared_deck
      login_as(default_user)

      get(shared_deck_path(deck.share_token))

      expect(rendered).to have_text("Add to My Decks")
    end

    it "returns not found for an unknown token" do
      get(shared_deck_path("does-not-exist"))

      expect(response).to have_http_status(:not_found)
    end

    it "returns not found after the token has been revoked" do
      deck = shared_deck
      token = deck.share_token
      deck.revoke_share_token!

      get(shared_deck_path(token))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#try" do
    it "creates a guest user without authentication" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Q", back: "A")
      params = { time_zone: "UTC" }

      expect { post(try_shared_deck_path(deck.share_token), params:) }
        .to change(User, :count).by(1)
    end

    it "assigns the guest role to the new user" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Q", back: "A")

      post(try_shared_deck_path(deck.share_token), params: { time_zone: "UTC" })

      expect(User.last.role).to eq("guest")
    end

    it "copies the shared deck to the guest user" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Q", back: "A")

      post(try_shared_deck_path(deck.share_token), params: { time_zone: "UTC" })

      expect(User.last.decks.first.name).to eq(deck.name)
    end

    it "stores the submitted time zone on the guest" do
      post(
        try_shared_deck_path(shared_deck.share_token),
        params: { time_zone: "America/New_York" },
      )

      expect(User.last.time_zone).to eq("America/New_York")
    end

    it "redirects to the study page" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Q", back: "A")

      post(try_shared_deck_path(deck.share_token), params: { time_zone: "UTC" })

      expect(response).to redirect_to(deck_study_path(Deck.last))
    end

    it "sets the demo session flag" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Q", back: "A")
      post(try_shared_deck_path(deck.share_token), params: { time_zone: "UTC" })

      follow_redirect!

      expect(rendered).to have_css(".demo-banner")
    end

    it "caps the copied cards at Demo::CreateGuestUser::CARD_LIMIT" do
      stub_const("Demo::CreateGuestUser::CARD_LIMIT", 2)
      deck = shared_deck
      3.times { |i| create(:basic_card, deck:, front: "Q#{i}", back: "A#{i}") }

      post(try_shared_deck_path(deck.share_token), params: { time_zone: "UTC" })

      expect(Deck.last.cards.count).to eq(2)
    end

    it "returns not found for an unknown token" do
      post(try_shared_deck_path("does-not-exist"))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#copy" do
    it "requires authentication" do
      deck = shared_deck

      post(copy_shared_deck_path(deck.share_token))

      expect(response).to redirect_to(new_session_path)
    end

    it "copies the deck and redirects to decks index" do
      deck = shared_deck
      create(:basic_card, deck:, front: "Q", back: "A")
      login_as(default_user)

      post(copy_shared_deck_path(deck.share_token))

      expect(response).to redirect_to(decks_path)
    end

    it "sets success flash message" do
      deck = shared_deck
      login_as(default_user)

      post(copy_shared_deck_path(deck.share_token))

      expect(flash[:success]).to eq("Deck copied successfully")
    end

    it "creates a new deck for the current user" do
      deck = shared_deck
      login_as(default_user)

      expect { post(copy_shared_deck_path(deck.share_token)) }
        .to change { default_user.decks.count }.by(1)
    end

    it "shows error when user already has deck with that name" do
      deck = shared_deck(name: "Existing")
      create(:deck, user: default_user, name: "Existing")
      login_as(default_user)

      post(copy_shared_deck_path(deck.share_token))

      expect(rendered).to have_text("Name has already been taken")
    end

    it "returns not found for an unknown token" do
      login_as(default_user)

      post(copy_shared_deck_path("does-not-exist"))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#create" do
    it "requires authentication" do
      deck = create(:deck)

      post(deck_share_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "generates a share token for the deck" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      expect { post(deck_share_path(deck)) }
        .to change { deck.reload.share_token }.from(nil)
    end

    it "redirects to the deck show page" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post(deck_share_path(deck))

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets success flash message" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post(deck_share_path(deck))

      expect(flash[:success]).to eq("Share link created")
    end

    it "does not allow sharing another user's deck" do
      other_deck = create(:deck, user: create(:user))
      login_as(default_user)

      post(deck_share_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#destroy" do
    it "requires authentication" do
      deck = create(:deck).tap(&:generate_share_token!)

      delete(deck_share_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "clears the share token on the deck" do
      deck = create(:deck, user: default_user).tap(&:generate_share_token!)
      login_as(default_user)

      expect { delete(deck_share_path(deck)) }
        .to change { deck.reload.share_token }.to(nil)
    end

    it "redirects to the deck show page" do
      deck = create(:deck, user: default_user).tap(&:generate_share_token!)
      login_as(default_user)

      delete(deck_share_path(deck))

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets success flash message" do
      deck = create(:deck, user: default_user).tap(&:generate_share_token!)
      login_as(default_user)

      delete(deck_share_path(deck))

      expect(flash[:success]).to eq("Share link revoked")
    end

    it "does not allow revoking another user's deck share" do
      other = create(:deck, user: create(:user)).tap(&:generate_share_token!)
      login_as(default_user)

      delete(deck_share_path(other))

      expect(response).to have_http_status(:not_found)
    end
  end
end
