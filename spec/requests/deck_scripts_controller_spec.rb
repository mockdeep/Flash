# frozen_string_literal: true

RSpec.describe DeckScriptsController do
  def update_script(deck, script)
    patch(deck_script_path(deck), params: { script: })
  end

  describe "#update" do
    it "sets the deck's script" do
      login_as(default_user)
      deck = create(:reading_deck)

      expect { update_script(deck, "traditional") }
        .to change_record(deck, :script).to("traditional")
    end

    it "goes back to the study page" do
      login_as(default_user)
      deck = create(:reading_deck)

      update_script(deck, "traditional")

      expect(response).to redirect_to(deck_study_path(deck))
    end

    it "refuses a script a deck can't study in" do
      login_as(default_user)
      deck = create(:reading_deck)

      update_script(deck, "pinyin")

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "is not found for another user's deck" do
      login_as(default_user)
      deck = create(:reading_deck, user: create(:user))

      update_script(deck, "traditional")

      expect(response).to have_http_status(:not_found)
    end
  end
end
