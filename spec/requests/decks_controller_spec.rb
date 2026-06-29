# frozen_string_literal: true

RSpec.describe DecksController do
  describe "#index" do
    it "renders the empty state when user has no decks" do
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_text("No Decks Yet")
    end

    it "renders decks grid when user has decks" do
      login_as(default_user)
      create(:deck, user: default_user, name: "My Test Deck")

      get(decks_path)

      expect(rendered).to have_text("My Test Deck")
    end

    it "shows card count for each deck" do
      login_as(default_user)
      deck = create(:deck, user: default_user)
      create(:card, deck:)

      get(decks_path)

      expect(rendered).to have_text("1")
    end

    it "shows 'No cards yet' for empty deck" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_text("No cards yet")
    end

    it "shows stats for deck with cards" do
      deck = create(:deck, user: default_user)
      create(:card, deck:)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_text("Remaining")
    end

    it "shows filled stars for completed levels" do
      deck = create(:deck, user: default_user, level: 3)
      create(:card, deck:)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_css(".star--filled", count: 2)
    end

    context "with pending suggestions" do
      def seed_pending_for(deck)
        card = create(:card, deck:)
        create(:card_suggestion, card:)
      end

      it "renders a count badge on decks with pending suggestions" do
        deck = create(:deck, user: default_user, name: "Geo")
        2.times { seed_pending_for(deck) }
        login_as(default_user)

        get(decks_path)

        expect(rendered).to have_text("2 pending suggestions")
      end

      it "links the badge to the deck's suggestions page" do
        deck = create(:deck, user: default_user)
        seed_pending_for(deck)
        login_as(default_user)

        get(decks_path)

        expect(rendered).to have_link(href: deck_suggestions_path(deck))
      end

      it "shows the filter chip when any deck has pending suggestions" do
        deck = create(:deck, user: default_user)
        seed_pending_for(deck)
        login_as(default_user)

        get(decks_path)

        expect(rendered).to have_css(".filter-chip")
      end

      it "hides the filter chip when no deck has pending suggestions" do
        create(:deck, user: default_user)
        login_as(default_user)

        get(decks_path)

        expect(rendered).to have_no_css(".filter-chip")
      end

      it "filters to decks with pending suggestions when filter is active" do
        create(:deck, user: default_user, name: "Plain")
        seed_pending_for(create(:deck, user: default_user, name: "Hot"))
        login_as(default_user)

        get(decks_path, params: { filter: "pending_suggestions" })

        expect(rendered).to(have_text("Hot").and(have_no_text("Plain")))
      end

      it "marks the filter chip active when the filter is applied" do
        deck = create(:deck, user: default_user)
        seed_pending_for(deck)
        login_as(default_user)

        get(decks_path, params: { filter: "pending_suggestions" })

        expect(rendered).to have_css(".filter-chip--active")
      end
    end

    it "shows a catalog badge for a public deck" do
      create(:deck, user: default_user, visibility: "public")
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_css("[title='In catalog']")
    end

    it "does not show a catalog badge for a private deck" do
      create(:deck, user: default_user, visibility: "private")
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_no_css("[title='In catalog']")
    end
  end

  describe "#show" do
    it "renders the deck page" do
      deck = create(:deck)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text(deck.name)
    end

    it "shows empty message when deck has no cards" do
      deck = create(:deck)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("no cards yet")
    end

    it "shows card table when deck has cards" do
      deck = create(:deck)
      create(:card, deck:, front: "Test Front", back: "Test Back")
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Test Front")
    end

    it "shows study link when deck has cards" do
      deck = create(:deck)
      create(:card, deck:)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Study Deck")
    end

    def deck_with_card
      create(:card, deck: create(:deck)).deck
    end

    it "shows the create-reverse button for a forward deck" do
      deck = deck_with_card
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Create reverse deck")
    end

    it "hides the create-reverse button once a reverse exists" do
      deck = deck_with_card
      Decks::CreateReverse.call(source: deck)
      login_as(default_user)
      get(deck_path(deck))

      expect(rendered).to have_no_text("Create reverse deck")
    end

    it "hides the create-reverse button on a reverse deck" do
      reverse = Decks::CreateReverse.call(source: deck_with_card).record
      login_as(default_user)

      get(deck_path(reverse))

      expect(rendered).to have_no_text("Create reverse deck")
    end

    it "prevents viewing another user's deck" do
      other_deck = create(:deck, user: create(:user))
      login_as(default_user)

      get(deck_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end

    it "shows a share button when the deck is not shared" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_button("Share Link")
    end

    it "shows a revoke button when the deck is shared" do
      deck = create(:deck, user: default_user)
      deck.generate_share_token!
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Revoke Link")
    end

    it "shows the share URL when the deck is shared" do
      deck = create(:deck, user: default_user).tap(&:generate_share_token!)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered)
        .to have_field(type: "text", with: shared_deck_url(deck.share_token))
    end

    it "shows the Replace cards link for a text deck" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_link("Replace cards")
    end

    it "does not show the Replace cards link for a music deck" do
      deck = create(:music_deck, user: default_user)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_no_link("Replace cards")
    end

    it "shows 'Add to Catalog' for an admin owner of a private deck" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin)
      login_as(admin)

      get(deck_path(deck))

      expect(rendered).to have_button("Add to Catalog")
    end

    it "shows 'Remove from Catalog' for an admin owner of a public deck" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin, visibility: "public")
      login_as(admin)

      get(deck_path(deck))

      expect(rendered).to have_button("Remove from Catalog")
    end

    it "does not show catalog buttons for a non-admin owner" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_no_button("Add to Catalog")
    end
  end

  describe "#destroy" do
    it "deletes the deck" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      expect { delete(deck_path(deck)) }.to change(Deck, :count).by(-1)
    end

    it "deletes the deck's cards" do
      deck = create(:deck, user: default_user)
      create(:card, deck:)
      login_as(default_user)

      expect { delete(deck_path(deck)) }.to change(Card, :count).by(-1)
    end

    it "deletes the deck's incoming suggestions" do
      deck = create(:deck, user: default_user)
      create(:card_suggestion, card: create(:card, deck:))
      login_as(default_user)

      expect { delete(deck_path(deck)) }
        .to change(CardSuggestion, :count).by(-1)
    end

    it "redirects to the decks index" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      delete(deck_path(deck))

      expect(response).to redirect_to(decks_path)
    end

    it "sets a success flash" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      delete(deck_path(deck))

      expect(flash[:success]).to eq("Deck deleted")
    end

    it "prevents deleting another user's deck" do
      other_deck = create(:deck, user: create(:user))
      login_as(default_user)

      delete(deck_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end

    it "does not delete another user's deck" do
      other_deck = create(:deck, user: create(:user))
      login_as(default_user)

      expect { delete(deck_path(other_deck)) }.not_to change(Deck, :count)
    end
  end

  describe "#new" do
    it "renders the new deck form" do
      login_as(default_user)

      get(new_deck_path)

      expect(rendered).to have_text("Create New Deck")
    end
  end

  describe "#create" do
    def deck_params(name:, csv_file:, deck_type: nil)
      attrs = { name:, cards_csv: csv_file }
      attrs[:deck_type] = deck_type if deck_type
      { deck: attrs }
    end

    context "when deck creation succeeds" do
      it "redirects to decks index" do
        csv = fixture_file_upload("decks/basic.csv", "text/csv")
        login_as(default_user)

        post(decks_path, params: deck_params(name: "Test", csv_file: csv))

        expect(response).to redirect_to(decks_path)
      end

      it "sets success flash message" do
        csv = fixture_file_upload("decks/basic.csv", "text/csv")
        login_as(default_user)

        post(decks_path, params: deck_params(name: "Test", csv_file: csv))

        expect(flash[:success]).to eq("Deck created successfully")
      end
    end

    context "when deck creation fails" do
      it "renders new deck form" do
        csv = fixture_file_upload("decks/basic.csv", "text/csv")
        login_as(default_user)

        post(decks_path, params: deck_params(name: "", csv_file: csv))

        expect(rendered).to have_text("Create New Deck")
      end

      it "sets error flash message" do
        csv = fixture_file_upload("decks/basic.csv", "text/csv")
        login_as(default_user)

        post(decks_path, params: deck_params(name: "", csv_file: csv))

        expect(flash.now[:error]).to eq("Name can't be blank")
      end
    end

    context "when deck_type is 'music'" do
      def post_music_deck(name: "Music Test")
        csv = fixture_file_upload("decks/music.csv", "text/csv")
        login_as(default_user)
        post(
          decks_path,
          params: deck_params(name:, csv_file: csv, deck_type: "music"),
        )
      end

      it "creates a MusicDeck" do
        expect { post_music_deck }.to change(MusicDeck, :count).by(1)
      end

      it "does not create a TextDeck" do
        expect { post_music_deck }.not_to change(TextDeck, :count)
      end

      it "redirects to decks index" do
        post_music_deck

        expect(response).to redirect_to(decks_path)
      end

      it "re-renders the form when validation fails" do
        post_music_deck(name: "")

        expect(rendered).to have_text("Create New Deck")
      end
    end
  end
end
