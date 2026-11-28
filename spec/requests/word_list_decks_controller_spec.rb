# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordListDecksController do
  def login_admin
    create(:user, :admin).tap { |admin| login_as(admin) }
  end

  def public_list = create(:word_list, visibility: "public")

  describe "#create" do
    it "starts a list for a member" do
      login_as(default_user)
      list = public_list

      post(word_list_deck_path(list))

      expect(default_user.decks.sole.word_list).to eq(list)
    end

    it "sends a visitor to log in" do
      post(word_list_deck_path(public_list))

      expect(response).to redirect_to(new_session_path)
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

      expect(admin.decks.sole).to have_attributes(word_list: list)
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
