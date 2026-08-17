# frozen_string_literal: true

RSpec.describe DecksController do
  describe "#index" do
    it "renders the empty state when user has no decks" do
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_text("No Decks Yet")
    end

    it "renders the deck rail when user has decks" do
      login_as(default_user)
      create(:deck, user: default_user, name: "My Test Deck")

      get(decks_path)

      expect(rendered).to have_text("My Test Deck")
    end

    it "titles a rail card for a deck without a word_list" do
      login_as(default_user)
      create(:deck, user: default_user, name: "Flat Deck", word_list: nil)

      get(decks_path)

      expect(rendered).to have_link("Flat Deck")
    end

    def deck_in_topic(name)
      deck = create(:deck, user: default_user)
      topic = create(:topic, name:, user: default_user)
      deck.update!(topic:)
      deck
    end

    it "groups decks under their topic heading" do
      login_as(default_user)
      deck_in_topic("Mandarin")

      get(decks_path)

      expect(rendered).to have_css("h2", text: "Mandarin")
    end

    it "lists un-topiced decks under 'Other Decks' when topics exist" do
      login_as(default_user)
      deck_in_topic("Mandarin")
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_css("h2", text: "Other Decks")
    end

    it "omits the 'Other Decks' heading when no topics exist" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_no_css("h2", text: "Other Decks")
    end

    it "shows the deck count in a topic heading" do
      login_as(default_user)
      deck_in_topic("Mandarin")

      get(decks_path)

      expect(rendered).to have_css(".topic-meta", text: "1 deck")
    end

    it "shows 'No cards yet' for empty deck" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_text("No cards yet")
    end

    it "shows the remaining count for a deck with cards" do
      deck = create(:deck, user: default_user)
      create(:basic_card, deck:)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_text("1 left")
    end

    it "labels each deck with its type" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_css(".rail-type", text: "Basic")
    end

    it "links the deck name to the deck page" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_link(deck.name, href: deck_path(deck))
    end

    it "links each deck with pending cards to its study page" do
      deck = create(:deck, user: default_user)
      create(:basic_card, deck:)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_link("Study →", href: deck_study_path(deck))
    end

    it "omits the study link for a deck with no cards" do
      create(:deck, user: default_user)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_no_link("Study →")
    end

    it "shows Done for a deck whose cards are all done" do
      deck = create(:deck, user: default_user)
      create(:basic_card, deck:, correct_streak: 1)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_text("Done ✓")
    end

    it "offers Review instead of Study when a deck is done" do
      deck = create(:deck, user: default_user)
      create(:basic_card, deck:, correct_streak: 1)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_link("Review →", href: deck_study_path(deck))
    end

    def studied_deck(name, at)
      create(:deck, user: default_user, name:, last_studied_at: at)
    end

    it "spotlights the most recently studied deck" do
      login_as(default_user)
      studied_deck("Old", 2.days.ago)
      studied_deck("New", 1.hour.ago)

      get(decks_path)

      expect(rendered).to have_css(".rail-card--mru .rail-title", text: "New")
    end

    it "notes when the spotlighted deck was last studied" do
      login_as(default_user)
      create(:deck, user: default_user, last_studied_at: 1.hour.ago)

      get(decks_path)

      expect(rendered).to have_text("Last studied about 1 hour ago")
    end

    it "keeps the spotlighted deck in its natural position as well" do
      login_as(default_user)
      create(:deck, user: default_user, last_studied_at: 1.hour.ago)

      get(decks_path)

      expect(rendered).to have_css(".rail-card", count: 2)
    end

    it "renders no spotlight when nothing has been studied" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_no_css(".rail-card--mru")
    end

    def mixed_types
      create(:reading_deck, user: default_user)
      create(:deck, user: default_user)
    end

    it "renders type tabs when a section mixes deck types" do
      login_as(default_user)
      mixed_types

      get(decks_path)

      expect(rendered).to have_css(".rail-tab", text: "Reading")
    end

    it "counts each type in its tab" do
      login_as(default_user)
      mixed_types

      get(decks_path)

      expect(rendered).to have_css(".rail-tab", text: /All\s*2/)
    end

    it "marks the All tab active on render" do
      login_as(default_user)
      mixed_types

      get(decks_path)

      expect(rendered).to have_css(".rail-tab--active", text: "All")
    end

    it "omits the tab bar when a section has one deck type" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_no_css(".rail-tab")
    end

    it "tags each card with its deck type for filtering" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_css(".rail-card[data-filter-value='Basic']")
    end

    it "keys the filter controller by topic for remembered tabs" do
      login_as(default_user)
      deck = deck_in_topic("Mandarin")

      get(decks_path)

      expect(rendered)
        .to have_css("[data-filter-key-value='topic-#{deck.topic.id}']")
    end

    it "keys the topicless section as 'other'" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered).to have_css("[data-filter-key-value='other']")
    end

    it "renders the scroll arrows hidden for the controller to reveal" do
      login_as(default_user)
      create(:deck, user: default_user)

      get(decks_path)

      expect(rendered)
        .to have_css(".rail-arrow[hidden]", count: 2, visible: :hidden)
    end

    it "spotlights per topic, not across the whole page" do
      login_as(default_user)
      deck_in_topic("Mandarin").update!(last_studied_at: 1.hour.ago)
      deck_in_topic("Music")

      get(decks_path)

      expect(rendered).to have_css(".rail-card--mru", count: 1)
    end

    it "shows filled segments for completed levels" do
      deck = create(:deck, user: default_user, level: 3)
      create(:basic_card, deck:)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_css(".level-fill--done", count: 2)
    end

    def seed_half_done_deck
      deck = create(:deck, user: default_user)
      create(:basic_card, :done, deck:)
      create(:basic_card, deck:)
    end

    it "partially fills the current level's segment" do
      seed_half_done_deck
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_css(".level-fill[style='width: 50%']")
    end

    it "marks decks past the final level as complete" do
      deck = create(:deck, user: default_user, level: 4)
      create(:basic_card, deck:)
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_css(".level-tag--complete", text: "Complete ✓")
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
      create(:basic_card, deck:, front: "Test Front", back: "Test Back")
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Test Front")
    end

    it "shows study link when deck has cards" do
      deck = create(:deck)
      create(:basic_card, deck:)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Study Deck")
    end

    def deck_with_card
      create(:reading_card, deck: create(:reading_deck)).deck
    end

    it "shows the topic form when the deck has no topic" do
      deck = deck_with_card
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_button("Add to topic")
    end

    def deck_in_topic(name)
      deck = deck_with_card
      topic = create(:topic, name:, user: default_user)
      deck.update!(topic:)
      deck
    end

    it "shows the assigned topic" do
      deck = deck_in_topic("Mandarin")
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_text("Topic: Mandarin")
    end

    it "suggests the user's existing topics in the topic form" do
      create(:topic, name: "Mandarin", user: default_user)
      login_as(default_user)

      get(deck_path(deck_with_card))

      expect(rendered)
        .to have_css("datalist option[value='Mandarin']", visible: :all)
    end

    it "does not suggest another user's topics" do
      create(:topic, name: "Mandarin", user: create(:user))
      login_as(default_user)

      get(deck_path(deck_with_card))

      expect(rendered)
        .to have_no_css("datalist option[value='Mandarin']", visible: :all)
    end

    it "offers no create-reverse button" do
      deck = deck_with_card
      login_as(default_user)

      get(deck_path(deck))

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
      create(:basic_card, deck:)
      login_as(default_user)

      expect { delete(deck_path(deck)) }.to change(Card, :count).by(-1)
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

    # Language decks are no longer creatable; a submission naming that type
    # (a stale form, a hand-rolled POST) falls through to Basic rather than
    # erroring, since a freeform CSV is exactly what a Basic deck is for.
    context "when deck_type is 'language'" do
      def post_language_deck
        csv = fixture_file_upload("decks/basic.csv", "text/csv")
        login_as(default_user)
        post(
          decks_path,
          params: deck_params(
            name: "Vocab", csv_file: csv, deck_type: "language",
          ),
        )
      end

      it "creates a basic deck instead" do
        post_language_deck

        expect(default_user.decks.sole).to be_a(BasicDeck)
      end

      it "creates no word_list" do
        expect { post_language_deck }.not_to change(WordList, :count)
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

      it "does not create a BasicDeck" do
        expect { post_music_deck }.not_to change(BasicDeck, :count)
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
