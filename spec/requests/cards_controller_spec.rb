# frozen_string_literal: true

RSpec.describe CardsController do
  def update_card(
    deck:,
    card:,
    front: "New Front",
    back: "Original Back",
    category: "Science"
  )
    login_as(default_user)
    patch(
      deck_card_path(deck, card),
      params: { card: { front:, back:, category: } },
    )
  end

  describe "#update" do
    context "when update succeeds" do
      it "updates the card" do
        deck = create(:deck)
        card = create(:card, deck:, front: "Original Front")

        expect { update_card(deck:, card:) }
          .to change_record(card, :front)
          .from("Original Front").to("New Front")
      end

      it "replaces the card question on the page" do
        deck = create(:deck)
        card = create(:card, deck:, front: "Original Front")
        update_card(deck:, card:, front: "Updated Front")

        expect(rendered).to have_css("turbo-stream[target='card-question']")
      end

      it "replaces the edit form frame" do
        deck = create(:deck)
        card = create(:card, deck:)
        update_card(deck:, card:)

        expect(rendered).to have_css("turbo-stream[target='card_edit_form']")
      end

      it "returns ok status" do
        deck = create(:deck)
        card = create(:card, deck:)
        update_card(deck:, card:)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when update fails" do
      it "does not update the card" do
        deck = create(:deck)
        card = create(:card, deck:, front: "Original Front")

        expect { update_card(deck:, card:, front: "") }
          .not_to change_record(card, :front)
      end

      it "returns unprocessable content status" do
        deck = create(:deck)
        card = create(:card, deck:)
        update_card(deck:, card:, front: "")

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders validation errors" do
        deck = create(:deck)
        card = create(:card, deck:)
        update_card(deck:, card:, front: "")

        expect(rendered).to have_css(".error-explanation")
      end

      it "re-renders the edit form frame" do
        deck = create(:deck)
        card = create(:card, deck:)
        update_card(deck:, card:, front: "")

        expect(rendered).to have_css("turbo-frame#card_edit_form")
      end
    end

    it "returns unprocessable content for duplicates" do
      deck = create(:deck)
      create(:card, deck:, front: "Existing Front")
      card = create(:card, deck:, front: "Other Front")
      update_card(deck:, card:, front: "Existing Front")

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "prevents updating another user's card" do
      other_deck = create(:deck, user: create(:user))
      other_card = create(:card, deck: other_deck)
      login_as(default_user)
      patch_card(other_deck, other_card, front: "Hacked")

      expect(response).to have_http_status(:not_found)
    end
  end

  context "when not authenticated" do
    it "redirects to sign in" do
      deck = create(:deck)
      card = create(:card, deck:)
      patch_card(deck, card, front: "New Front")

      expect(response).to redirect_to(new_session_path)
    end
  end

  def patch_card(deck, card, **attrs)
    patch(deck_card_path(deck, card), params: { card: attrs })
  end
end
