# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordListDecksController do
  def login_admin
    create(:user, :admin).tap { |admin| login_as(admin) }
  end

  def public_list = create(:word_list, visibility: "public")

  describe "#create" do
    it "is not found for a member" do
      login_as(default_user)

      post(word_list_deck_path(public_list))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for a list the user can't see" do
      login_admin

      post(word_list_deck_path(create(:word_list)))

      expect(response).to have_http_status(:not_found)
    end

    it "makes a deck over the whole of a list with no source" do
      admin = login_admin
      list = public_list

      post(word_list_deck_path(list))

      expect(admin.decks.sole).to have_attributes(word_list: list, snippet: nil)
    end

    it "makes a deck for a source's first section" do
      admin = login_admin
      snippet = create(:snippet, :finished, word_list: public_list)

      post(word_list_deck_path(snippet.word_list))

      expect(admin.decks.sole.snippet).to eq(snippet)
    end

    it "opens the deck's study page" do
      admin = login_admin

      post(word_list_deck_path(public_list))

      expect(response).to redirect_to(deck_study_path(admin.decks.sole))
    end

    it "opens the deck the user already has" do
      admin = login_admin
      deck = create(:reading_deck, user: admin, word_list: public_list)

      post(word_list_deck_path(deck.word_list))

      expect(response).to redirect_to(deck_study_path(deck))
    end
  end
end
