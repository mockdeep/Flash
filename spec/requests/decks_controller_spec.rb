# frozen_string_literal: true

require "rails_helper"

RSpec.describe DecksController do
  describe "#index" do
    it "renders the decks index page" do
      login_as(default_user)

      get(decks_path)

      expect(rendered).to have_content("My Decks")
    end
  end

  describe "#show" do
    it "renders the deck page" do
      deck = create(:deck)
      login_as(default_user)

      get(deck_path(deck))

      expect(rendered).to have_content(deck.name)
    end

    it "prevents viewing another user's deck" do
      other_deck = create(:deck, user: create(:user))
      login_as(default_user)

      get(deck_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#new" do
    it "renders the new deck form" do
      login_as(default_user)

      get(new_deck_path)

      expect(rendered).to have_content("Create New Deck")
    end
  end

  describe "#create" do
    def deck_params(name:, csv_file:)
      {
        deck: {
          name: name,
          cards_csv: csv_file,
        },
      }
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

        expect(rendered).to have_content("Create New Deck")
      end

      it "sets error flash message" do
        csv = fixture_file_upload("decks/basic.csv", "text/csv")
        login_as(default_user)

        post(decks_path, params: deck_params(name: "", csv_file: csv))

        expect(flash.now[:error]).to eq("There was a problem creating the deck")
      end
    end
  end
end
