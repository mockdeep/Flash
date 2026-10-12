# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceDecksController do
  def admin_source
    admin = create(:user, :admin)
    login_as(admin)
    create(:source, word_list: create(:word_list, user: admin))
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)

      post(source_deck_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "creates a reading deck over the source's word_list" do
      source = admin_source

      post(source_deck_path(source))

      expect(source.word_list.user.decks.last)
        .to have_attributes(type: "ReadingDeck", word_list: source.word_list)
    end

    it "reuses the deck the admin already has over the list" do
      source = admin_source
      word_list = source.word_list
      create(:reading_deck, user: word_list.user, word_list:)

      expect { post(source_deck_path(source)) }.not_to change(Deck, :count)
    end

    it "redirects to studying the deck" do
      source = admin_source

      post(source_deck_path(source))

      deck = source.word_list.user.decks.last
      expect(response).to redirect_to(deck_study_path(deck))
    end
  end
end
