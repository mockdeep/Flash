# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetDecksController do
  def admin_snippet
    admin = create(:user, :admin)
    login_as(admin)
    create(:snippet, word_list: create(:word_list, user: admin))
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      post(snippet_deck_path(create(:snippet)))

      expect(response).to have_http_status(:not_found)
    end

    it "creates a reading deck over the snippet's word_list" do
      snippet = admin_snippet

      post(snippet_deck_path(snippet))

      expect(snippet.word_list.user.decks.last)
        .to have_attributes(type: "ReadingDeck", word_list: snippet.word_list)
    end

    it "reuses the deck the admin already has over the list" do
      snippet = admin_snippet
      word_list = snippet.word_list
      create(:reading_deck, user: word_list.user, word_list:)

      expect { post(snippet_deck_path(snippet)) }.not_to change(Deck, :count)
    end

    it "redirects to the deck" do
      snippet = admin_snippet

      post(snippet_deck_path(snippet))

      deck = snippet.word_list.user.decks.last
      expect(response).to redirect_to(deck_path(deck))
    end
  end
end
