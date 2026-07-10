# frozen_string_literal: true

RSpec.describe ReversalsController do
  def reversible_deck
    deck = create(:reading_deck, user: default_user)
    create(:card, deck:)
    deck
  end

  describe "#create" do
    it "requires authentication" do
      post(deck_reversal_path(create(:deck)))

      expect(response).to redirect_to(new_session_path)
    end

    it "creates a reverse deck" do
      deck = reversible_deck
      login_as(default_user)

      expect { post(deck_reversal_path(deck)) }
        .to change(WritingDeck, :count).by(1)
    end

    it "redirects to the new reverse deck" do
      deck = reversible_deck
      login_as(default_user)

      post(deck_reversal_path(deck))

      expect(response).to redirect_to(deck_path(WritingDeck.last))
    end

    it "sets a success flash" do
      deck = reversible_deck
      login_as(default_user)

      post(deck_reversal_path(deck))

      expect(flash[:success]).to eq("Reverse deck created")
    end

    it "sets an error flash when the deck cannot be reversed" do
      deck = reversible_deck
      login_as(default_user)
      post(deck_reversal_path(deck))

      post(deck_reversal_path(deck))

      expect(flash[:error]).to eq("This deck can't be reversed")
    end

    it "returns not found for another user's deck" do
      login_as(default_user)

      post(deck_reversal_path(create(:deck, user: create(:user))))

      expect(response).to have_http_status(:not_found)
    end
  end
end
