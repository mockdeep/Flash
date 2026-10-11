# frozen_string_literal: true

require "rails_helper"

RSpec.describe LookupsController do
  def admin_deck_with_sense
    admin = create(:user, :admin)
    login_as(admin)
    deck = create(:reading_deck, user: admin)
    sense = create(:sense)
    create(:sense_membership, word_list: deck.word_list, sense:)
    [deck, sense]
  end

  def score_for(deck, sense)
    SkillScore.find_by(user: deck.user, sense:, skill: "reading")
  end

  describe "#create" do
    it "is not found for a user who is not an admin" do
      login_as(default_user)
      deck = create(:reading_deck)

      post(deck_lookups_path(deck), params: { sense_id: create(:sense).id })

      expect(response).to have_http_status(:not_found)
    end

    it "resets the user's streak on the sense" do
      deck, sense = admin_deck_with_sense
      create(:skill_score, user: deck.user, sense:, correct_streak: 3)

      post(deck_lookups_path(deck), params: { sense_id: sense.id })

      expect(score_for(deck, sense).correct_streak).to eq(0)
    end

    it "counts the lookup as a view" do
      deck, sense = admin_deck_with_sense
      create(:skill_score, user: deck.user, sense:, view_count: 2)

      post(deck_lookups_path(deck), params: { sense_id: sense.id })

      expect(score_for(deck, sense).view_count).to eq(3)
    end

    it "creates the score when the user has none on the sense" do
      deck, sense = admin_deck_with_sense

      post(deck_lookups_path(deck), params: { sense_id: sense.id })

      expect(score_for(deck, sense)).to be_present
    end

    it "responds with no content" do
      deck, sense = admin_deck_with_sense

      post(deck_lookups_path(deck), params: { sense_id: sense.id })

      expect(response).to have_http_status(:no_content)
    end

    it "is not found for a sense outside the deck's list" do
      deck, = admin_deck_with_sense

      post(deck_lookups_path(deck), params: { sense_id: create(:sense).id })

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's deck" do
      _, sense = admin_deck_with_sense
      deck = create(:reading_deck, user: create(:user))

      post(deck_lookups_path(deck), params: { sense_id: sense.id })

      expect(response).to have_http_status(:not_found)
    end
  end
end
