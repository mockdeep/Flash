# frozen_string_literal: true

RSpec.describe DeckSectionsController do
  def pick_section(deck, snippet)
    post(deck_section_path(deck), params: { snippet_id: snippet.id })
  end

  def deck_with_section(user: default_user)
    snippet = create(:snippet, :finished)
    [create(:reading_deck, word_list: snippet.word_list, user:), snippet]
  end

  describe "#create" do
    it "makes the user's deck for the section" do
      login_as(default_user)
      deck, snippet = deck_with_section

      expect { pick_section(deck, snippet) }
        .to change { Deck.where(snippet:).count }.by(1)
    end

    it "opens the section's deck" do
      login_as(default_user)
      deck, snippet = deck_with_section

      pick_section(deck, snippet)

      expect(response).to redirect_to(deck_study_path(Deck.find_by(snippet:)))
    end

    it "reuses the user's deck for a section picked before" do
      login_as(default_user)
      deck, snippet = deck_with_section
      pick_section(deck, snippet)

      expect { pick_section(deck, snippet) }.not_to change(Deck, :count)
    end

    it "is not found for a section of another source" do
      login_as(default_user)
      deck, = deck_with_section

      pick_section(deck, create(:snippet, :finished))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for a section not yet processed" do
      login_as(default_user)
      deck, = deck_with_section

      pick_section(deck, create(:snippet, word_list: deck.word_list))

      expect(response).to have_http_status(:not_found)
    end

    it "is not found for another user's deck" do
      login_as(default_user)
      deck, snippet = deck_with_section(user: create(:user))

      pick_section(deck, snippet)

      expect(response).to have_http_status(:not_found)
    end
  end
end
