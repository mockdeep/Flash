# frozen_string_literal: true

RSpec.describe CatalogListingsController do
  describe "#create" do
    it "requires authentication" do
      deck = create(:deck)

      post(deck_catalog_listing_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "flips visibility to public for an admin owner" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin)
      login_as(admin)

      expect { post(deck_catalog_listing_path(deck)) }
        .to change { deck.reload.visibility }.from("private").to("public")
    end

    it "redirects to the deck show page" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin)
      login_as(admin)

      post(deck_catalog_listing_path(deck))

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets success flash message" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin)
      login_as(admin)

      post(deck_catalog_listing_path(deck))

      expect(flash[:success]).to eq("Deck added to catalog")
    end

    it "returns not found for a non-admin owner" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post(deck_catalog_listing_path(deck))

      expect(response).to have_http_status(:not_found)
    end

    it "does not change visibility for a non-admin owner" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      expect { post(deck_catalog_listing_path(deck)) }
        .not_to(change { deck.reload.visibility })
    end

    it "returns not found when an admin targets another user's deck" do
      admin = create(:user, :admin)
      other_deck = create(:deck, user: create(:user))
      login_as(admin)

      post(deck_catalog_listing_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#destroy" do
    it "requires authentication" do
      deck = create(:deck, visibility: "public")

      delete(deck_catalog_listing_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "flips visibility to private for an admin owner" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin, visibility: "public")
      login_as(admin)

      expect { delete(deck_catalog_listing_path(deck)) }
        .to change { deck.reload.visibility }.from("public").to("private")
    end

    it "redirects to the deck show page" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin, visibility: "public")
      login_as(admin)

      delete(deck_catalog_listing_path(deck))

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets success flash message" do
      admin = create(:user, :admin)
      deck = create(:deck, user: admin, visibility: "public")
      login_as(admin)

      delete(deck_catalog_listing_path(deck))

      expect(flash[:success]).to eq("Deck removed from catalog")
    end

    it "returns not found for a non-admin owner" do
      deck = create(:deck, user: default_user, visibility: "public")
      login_as(default_user)

      delete(deck_catalog_listing_path(deck))

      expect(response).to have_http_status(:not_found)
    end

    it "returns not found when an admin targets another user's deck" do
      admin = create(:user, :admin)
      other_deck = create(:deck, user: create(:user), visibility: "public")
      login_as(admin)

      delete(deck_catalog_listing_path(other_deck))

      expect(response).to have_http_status(:not_found)
    end
  end
end
