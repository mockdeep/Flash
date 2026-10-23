# frozen_string_literal: true

RSpec.describe CatalogController do
  def public_deck(**attrs)
    owner = create(:user)
    create(:deck, user: owner, visibility: "public", **attrs)
  end

  describe "#index" do
    it "is where the old demo page now leads" do
      get("/demo")

      expect(response).to redirect_to("/catalog")
    end

    it "renders without authentication" do
      get(catalog_index_path)

      expect(response).to have_http_status(:ok)
    end

    it "shows public decks" do
      public_deck(name: "Public Deck")

      get(catalog_index_path)

      expect(rendered).to have_text("Public Deck")
    end

    def listed_source
      snippet = create(:snippet, :finished, word_list: create(:word_list))
      create(:source_listing, source: snippet.source).source
    end

    it "links a listed source's name to its preview" do
      source = listed_source

      get(catalog_index_path)

      expect(rendered).to have_link(href: catalog_source_path(source))
    end

    it "offers a visitor a try of a listed source" do
      source = listed_source

      get(catalog_index_path)

      expect(rendered)
        .to have_css("form[action='#{try_catalog_source_path(source)}']")
    end

    def public_reading_deck(name)
      create(:reading_deck, user: create(:user), visibility: "public", name:)
    end

    it "sorts listed sources among a language's public decks by name" do
      ["Zebra", "Apple"].each { public_reading_deck(it) }
      listed_source.word_list.update!(name: "Mango")

      get(catalog_index_path)

      expect(rendered.all(".rail-title a").map(&:text))
        .to eq(["Apple", "Mango", "Zebra"])
    end

    it "groups public decks into sections" do
      public_deck
      owner = create(:user)
      create(:music_deck, user: owner, visibility: "public")

      get(catalog_index_path)

      expect(rendered).to have_css(".decks-section-title", count: 2)
    end

    it "links a deck's name to its preview" do
      deck = public_deck(name: "Public Deck")

      get(catalog_index_path)

      expect(rendered).to have_link("Public Deck", href: catalog_path(deck))
    end

    it "does not show private decks" do
      owner = create(:user)
      create(:deck, user: owner, name: "Secret", visibility: "private")

      get(catalog_index_path)

      expect(rendered).to have_no_text("Secret")
    end

    it "shows card count" do
      deck = public_deck
      create(:basic_card, deck:)

      get(catalog_index_path)

      expect(rendered).to have_text("1")
    end

    it "shows empty state when no public decks" do
      get(catalog_index_path)

      expect(rendered).to have_text("No Public Decks Yet")
    end

    it "shows a supporter badge next to subscriber-owned decks" do
      deck = public_deck
      create(:subscription, user: deck.user)

      get(catalog_index_path)

      expect(rendered).to have_css(".supporter-badge")
    end

    it "does not show a supporter badge for non-subscriber decks" do
      public_deck

      get(catalog_index_path)

      expect(rendered).to have_no_css(".supporter-badge")
    end

    it "shows a music badge for music decks" do
      owner = create(:user)
      create(:music_deck, user: owner, visibility: "public")

      get(catalog_index_path)

      expect(rendered).to have_css("[title='Microphone required']")
    end

    it "does not show a music badge for text decks" do
      public_deck

      get(catalog_index_path)

      expect(rendered).to have_no_css("[title='Microphone required']")
    end

    it "shows a texts badge for a deck with texts to read" do
      deck = create(:reading_deck, user: create(:user), visibility: "public")
      create(:source, word_list: deck.word_list, license: "public_domain")
      create(:snippet, :finished, word_list: deck.word_list)

      get(catalog_index_path)

      expect(rendered).to have_css("[title='Comes with texts to read']")
    end

    it "does not show a texts badge for a deck without them" do
      public_deck

      get(catalog_index_path)

      expect(rendered).to have_no_css("[title='Comes with texts to read']")
    end

    it "shows a try button for unauthenticated visitors" do
      public_deck

      get(catalog_index_path)

      expect(rendered).to have_button("Try This Deck")
    end

    it "tells unauthenticated visitors how many cards a demo has" do
      get(catalog_index_path)

      expect(rendered).to have_text("Demos include the first 100 cards")
    end

    it "shows a try button for guests" do
      deck = public_deck
      post(try_catalog_path(deck))

      get(catalog_index_path)

      expect(rendered).to have_button("Try This Deck")
    end

    it "does not show a try button for authenticated users" do
      public_deck
      login_as(default_user)

      get(catalog_index_path)

      expect(rendered).to have_no_button("Try This Deck")
    end

    it "links a deck already in the user's decks to its study page" do
      deck = public_deck
      copy = create(:deck, user: default_user, source_deck: deck)
      login_as(default_user)

      get(catalog_index_path)

      expect(rendered).to have_link("In your", href: deck_study_path(copy))
    end

    it "does not mark decks the user has not added" do
      public_deck
      login_as(default_user)

      get(catalog_index_path)

      expect(rendered).to have_no_link("In your decks")
    end

    it "invites authenticated users to add decks" do
      login_as(default_user)

      get(catalog_index_path)

      expect(rendered).to have_text("add them to your collection")
    end
  end

  describe "#show" do
    it "shows the source the deck's words came from" do
      deck = create(:reading_deck, user: create(:user), visibility: "public")
      create(:source, word_list: deck.word_list, title: "筷子")
      create(:snippet, :finished, word_list: deck.word_list)

      get(catalog_path(deck))

      expect(rendered).to have_css(".catalog-preview td", text: "筷子")
    end

    it "renders without authentication" do
      deck = public_deck

      get(catalog_path(deck))

      expect(response).to have_http_status(:ok)
    end

    it "shows deck name" do
      deck = public_deck(name: "Preview Deck")

      get(catalog_path(deck))

      expect(rendered).to have_text("Preview Deck")
    end

    it "shows card front in preview" do
      deck = public_deck
      create(:basic_card, deck:, front: "Question 1", back: "Answer 1")

      get(catalog_path(deck))

      expect(rendered).to have_text("Question 1")
    end

    it "shows card back in preview" do
      deck = public_deck
      create(:basic_card, deck:, front: "Question 1", back: "Answer 1")

      get(catalog_path(deck))

      expect(rendered).to have_text("Answer 1")
    end

    it "shows empty message when deck has no cards" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_text("This deck has no cards yet.")
    end

    it "shows card count" do
      deck = public_deck
      create(:basic_card, deck:)

      get(catalog_path(deck))

      expect(rendered).to have_text("1 cards")
    end

    it "shows deck owner" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_text("by #{deck.user.username}")
    end

    it "shows a supporter badge when the owner is a subscriber" do
      deck = public_deck
      create(:subscription, user: deck.user)

      get(catalog_path(deck))

      expect(rendered).to have_css(".supporter-badge")
    end

    it "does not show a supporter badge when the owner is not a subscriber" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_no_css(".supporter-badge")
    end

    it "shows a music badge for music decks" do
      deck = create(:music_deck, user: create(:user), visibility: "public")

      get(catalog_path(deck))

      expect(rendered).to have_css("[title='Microphone required']")
    end

    it "does not show a music badge for text decks" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_no_css("[title='Microphone required']")
    end

    it "limits preview to 5 cards" do
      deck = public_deck
      6.times { |i| create(:basic_card, deck:, front: "Q#{i}", back: "A#{i}") }

      get(catalog_path(deck))

      expect(rendered).to have_text("and 1 more cards...")
    end

    it "shows login prompt for unauthenticated visitors" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_text("Log in to Add Deck")
    end

    it "shows a try button for unauthenticated visitors" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_button("Try This Deck")
    end

    it "tells unauthenticated visitors how many cards a demo has" do
      deck = public_deck

      get(catalog_path(deck))

      expect(rendered).to have_text("Demos include the first 100 cards.")
    end

    it "shows a try button for guests" do
      deck = public_deck
      post(try_catalog_path(deck))

      get(catalog_path(deck))

      expect(rendered).to have_button("Try This Deck")
    end

    it "shows copy button for authenticated users" do
      deck = public_deck
      login_as(default_user)

      get(catalog_path(deck))

      expect(rendered).to have_text("Add to My Decks")
    end

    it "links to study a deck already in the user's decks" do
      deck = public_deck
      copy = create(:deck, user: default_user, source_deck: deck)
      login_as(default_user)

      get(catalog_path(deck))

      expect(rendered).to have_link("Study", href: deck_study_path(copy))
    end

    it "hides the copy button for a deck already in the user's decks" do
      deck = public_deck
      create(:deck, user: default_user, source_deck: deck)
      login_as(default_user)

      get(catalog_path(deck))

      expect(rendered).to have_no_button("Add to My Decks")
    end

    it "does not show a try button for authenticated users" do
      deck = public_deck
      login_as(default_user)

      get(catalog_path(deck))

      expect(rendered).to have_no_button("Try This Deck")
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
      create(:basic_card, deck:, front: "Q", back: "A")
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

      expect(rendered).to have_text("Name has already been taken")
    end
  end

  describe "#try" do
    def deck_with_card
      deck = public_deck
      create(:basic_card, deck:, front: "Q", back: "A")
      deck
    end

    def try_deck(deck: deck_with_card, time_zone: "UTC")
      post(try_catalog_path(deck), params: { time_zone: })
    end

    it "redirects to the study page" do
      try_deck

      expect(response).to redirect_to(deck_study_path(Deck.last))
    end

    it "shows the demo banner" do
      try_deck

      follow_redirect!
      expect(rendered).to have_css(".demo-banner")
    end

    it "creates a guest user" do
      deck = deck_with_card

      expect { try_deck(deck:) }.to change(User, :count).by(1)
    end

    it "assigns the guest role to the new user" do
      try_deck

      expect(User.last.role).to eq("guest")
    end

    it "stores the submitted time zone on the guest" do
      try_deck(time_zone: "America/New_York")

      expect(User.last.time_zone).to eq("America/New_York")
    end

    it "starts a fresh guest when a guest tries another deck" do
      try_deck
      first_guest = User.last

      try_deck
      expect(User.last).not_to eq(first_guest)
    end

    it "cleans up the guest when a real user logs in" do
      try_deck
      guest = User.last

      login_as(default_user)
      expect(User.exists?(guest.id)).to be(false)
    end

    it "handles an already-deleted guest gracefully" do
      try_deck
      User.last.destroy!

      login_as(default_user)
      expect(response).to redirect_to(root_path)
    end

    it "returns not found for private decks" do
      deck = create(:deck, user: create(:user), visibility: "private")

      post(try_catalog_path(deck))

      expect(response).to have_http_status(:not_found)
    end
  end
end
