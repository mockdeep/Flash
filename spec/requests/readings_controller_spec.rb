# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingsController do
  def reader_deck
    login_as(default_user)
    two_page_deck
  end

  def turn_to(deck, sentence)
    get(
      deck_reading_path(deck, sentence: sentence.id, token: 0),
      headers: { "Turbo-Frame" => "reading" },
    )
  end

  describe "#show" do
    it "shows the page holding the token" do
      deck, sentence = reader_deck

      turn_to(deck, sentence)

      expect(rendered).to have_css("turbo-frame#reading p", text: "你")
    end

    it "remembers the page as where the reader left off" do
      deck, sentence = reader_deck

      turn_to(deck, sentence)

      place = default_user.reading_places.find_by(source: deck.source)
      expect(place.snippet_sentence).to eq(sentence)
    end

    it "moves the reader's place on" do
      deck, sentence = reader_deck
      snippet_sentence = deck.snippet.sentences.first
      place = create(:reading_place, user: default_user, snippet_sentence:)

      expect { turn_to(deck, sentence) }
        .to change_record(place, :snippet_sentence_id).to(sentence.id)
    end

    it "sends a request from outside the frame to the study page" do
      deck, sentence = reader_deck

      get(deck_reading_path(deck, sentence: sentence.id, token: 0))

      expect(response).to redirect_to(deck_study_path(deck))
    end

    it "finds no page in a deck without text" do
      login_as(default_user)
      deck = create(:deck)

      get(deck_reading_path(deck), headers: { "Turbo-Frame" => "reading" })

      expect(response).to have_http_status(:not_found)
    end

    it "finds no page in someone else's deck" do
      _, sentence = reader_deck
      deck = create(:deck, user: create(:user))

      turn_to(deck, sentence)

      expect(response).to have_http_status(:not_found)
    end
  end
end
