# frozen_string_literal: true

require "rails_helper"

RSpec.describe MissesController do
  def deck_with_sense
    login_as(default_user)
    deck = create(:reading_deck)
    sense = create(:sense)
    create(:sense_membership, word_list: deck.word_list, sense:)
    [deck, sense]
  end

  def score_for(deck, sense)
    SkillScore.find_by(user: deck.user, sense:, skill: "reading")
  end

  describe "#create" do
    it "resets the user's streak on the sense" do
      deck, sense = deck_with_sense
      create(:skill_score, user: deck.user, sense:, correct_streak: 3)

      post(deck_misses_path(deck), params: { sense_id: sense.id })

      expect(score_for(deck, sense).correct_streak).to eq(0)
    end

    it "counts the miss as a view" do
      deck, sense = deck_with_sense
      create(:skill_score, user: deck.user, sense:, view_count: 2)

      post(deck_misses_path(deck), params: { sense_id: sense.id })

      expect(score_for(deck, sense).view_count).to eq(3)
    end

    it "creates the score when the user has none on the sense" do
      deck, sense = deck_with_sense

      post(deck_misses_path(deck), params: { sense_id: sense.id })

      expect(score_for(deck, sense)).to be_present
    end

    it "responds with no content" do
      deck, sense = deck_with_sense

      post(deck_misses_path(deck), params: { sense_id: sense.id })

      expect(response).to have_http_status(:no_content)
    end

    it "is not found for a sense outside the deck's list" do
      deck, = deck_with_sense

      post(deck_misses_path(deck), params: { sense_id: create(:sense).id })

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's deck" do
      _, sense = deck_with_sense
      deck = create(:reading_deck, user: create(:user))

      post(deck_misses_path(deck), params: { sense_id: sense.id })

      expect(response).to have_http_status(:not_found)
    end
  end
end
