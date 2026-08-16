# frozen_string_literal: true

RSpec.describe CardsController do
  def update_card(deck:, card:, **content)
    login_as(default_user)
    patch(
      deck_card_path(deck, card),
      params: { card: default_card.merge(content) },
    )
  end

  def default_card
    { front: "New Front", back: "Original Back", category: "Science" }
  end

  describe "#update" do
    context "when update succeeds" do
      it "updates the card's content" do
        deck = create(:deck)
        card = create(:basic_card, deck:, front: "Original Front")

        expect { update_card(deck:, card:) }
          .to change { card.reload.front }
          .from("Original Front").to("New Front")
      end

      it "edits the card's content in the data_set" do
        card = create(:basic_card, back: "old")
        update_card(deck: card.deck, card:, back: "new;fresh")

        expect(card.reload.back).to eq("new; fresh")
      end

      it "replaces the card question on the page" do
        deck = create(:deck)
        card = create(:basic_card, deck:, front: "Original Front")
        update_card(deck:, card:, front: "Updated Front")

        expect(rendered).to have_css("turbo-stream[target='card-question']")
      end

      it "replaces the edit form frame" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:)

        expect(rendered).to have_css("turbo-stream[target='card_edit_form']")
      end

      it "returns ok status" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when update fails" do
      it "does not update the card" do
        deck = create(:deck)
        card = create(:basic_card, deck:, front: "Original Front")

        expect { update_card(deck:, card:, front: "") }
          .not_to(change { card.reload.front })
      end

      it "rejects a blank back" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:, back: "")

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "rejects an example front without an example back" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:, example_front: "Bonjour")

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "rejects an example back without an example front" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:, example_back: "Hello")

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "returns unprocessable content status" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:, front: "")

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders validation errors" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:, front: "")

        expect(rendered).to have_css(".error-explanation")
      end

      it "re-renders the edit form frame" do
        deck = create(:deck)
        card = create(:basic_card, deck:)
        update_card(deck:, card:, front: "")

        expect(rendered).to have_css("turbo-frame#card_edit_form")
      end
    end

    it "returns unprocessable content for duplicates" do
      deck = create(:deck)
      create(:basic_card, deck:, front: "Existing Front")
      card = create(:basic_card, deck:, front: "Other Front")
      update_card(deck:, card:, front: "Existing Front")

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "prevents updating another user's card" do
      other_deck = create(:deck, user: create(:user))
      other_card = create(:basic_card, deck: other_deck)
      login_as(default_user)
      patch_card(other_deck, other_card, front: "Hacked")

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "#destroy" do
    it "deletes the card" do
      deck = create(:deck)
      card = create(:basic_card, deck:)
      login_as(default_user)

      expect { delete(deck_card_path(deck, card)) }
        .to change(Card, :count).by(-1)
    end

    it "removes a language card's items on delete" do
      card = create(:reading_card, back: "x")
      deck = card.deck
      login_as(default_user)
      delete(deck_card_path(deck, card))

      expect(deck.reload.data_set.items).to be_empty
    end

    it "redirects to the deck study path" do
      deck = create(:deck)
      card = create(:basic_card, deck:)
      login_as(default_user)

      delete(deck_card_path(deck, card))

      expect(response).to redirect_to(deck_study_path(deck))
    end

    it "sets a success flash" do
      deck = create(:deck)
      card = create(:basic_card, deck:)
      login_as(default_user)

      delete(deck_card_path(deck, card))

      expect(flash[:success]).to eq("Card deleted")
    end

    it "returns not_found for another user's card" do
      other_deck = create(:deck, user: create(:user))
      other_card = create(:basic_card, deck: other_deck)
      login_as(default_user)
      delete(deck_card_path(other_deck, other_card))

      expect(response).to have_http_status(:not_found)
    end

    it "does not delete another user's card" do
      other_deck = create(:deck, user: create(:user))
      other_card = create(:basic_card, deck: other_deck)
      login_as(default_user)

      expect { delete(deck_card_path(other_deck, other_card)) }
        .not_to change(Card, :count)
    end
  end

  context "when not authenticated" do
    it "redirects to sign in" do
      deck = create(:deck)
      card = create(:basic_card, deck:)
      patch_card(deck, card, front: "New Front")

      expect(response).to redirect_to(new_session_path)
    end
  end

  def patch_card(deck, card, **attrs)
    patch(deck_card_path(deck, card), params: { card: attrs })
  end
end
