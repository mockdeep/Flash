# frozen_string_literal: true

RSpec.describe ReplacementsController do
  def upload(content)
    Rack::Test::UploadedFile.new(
      StringIO.new(content),
      "text/csv",
      true,
      original_filename: "deck.csv",
    )
  end

  def replacement_params(content)
    { replacement: { cards_csv: upload(content) } }
  end

  def post_replace(deck, content)
    post(deck_replacement_path(deck), params: replacement_params(content))
  end

  def valid_csv
    "front,back,category\nQ,A,C\n"
  end

  describe "#new" do
    it "requires authentication" do
      deck = create(:deck)

      get(new_deck_replacement_path(deck))

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the replacement form for the deck owner" do
      deck = create(:deck, user: default_user, name: "My Deck")
      login_as(default_user)

      get(new_deck_replacement_path(deck))

      expect(rendered).to have_text("Replace cards in My Deck")
    end

    it "renders a confirmation prompt on the form" do
      login_as(default_user)

      get(new_deck_replacement_path(create(:deck, user: default_user)))

      expect(rendered).to have_css('form[data-controller~="confirm-submit"]')
    end

    it "returns not found for another user's deck" do
      login_as(default_user)

      get(new_deck_replacement_path(create(:deck, user: create(:user))))

      expect(response).to have_http_status(:not_found)
    end

    it "redirects with an error for a music deck" do
      deck = create(:music_deck, user: default_user)
      login_as(default_user)

      get(new_deck_replacement_path(deck))

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets the unsupported flash for a music deck" do
      login_as(default_user)

      get(new_deck_replacement_path(create(:music_deck, user: default_user)))

      expect(flash[:error]).to eq("Replace is only available for text decks")
    end
  end

  describe "#create" do
    it "requires authentication" do
      post_replace(create(:deck), valid_csv)

      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to the deck show page on success" do
      deck = create(:deck, user: default_user)
      login_as(default_user)

      post_replace(deck, valid_csv)

      expect(response).to redirect_to(deck_path(deck))
    end

    it "sets a summary flash on success" do
      deck = create(:deck, user: default_user)
      login_as(default_user)
      post_replace(deck, "front,back,category\nQ,A,C\n")

      expect(flash[:success])
        .to eq("Replaced cards: 1 added, 0 removed, 0 reset, 0 kept")
    end

    it "applies the diff" do
      deck = create(:deck, user: default_user)
      create(:basic_card, deck:, front: "Q", back: "A")
      login_as(default_user)

      post_replace(deck, "front,back,category\nQ,A,C\nNew,N,C\n")

      expect(deck.cards.map { |c| c.item.text }).to contain_exactly("Q", "New")
    end

    it "re-renders the form on invalid CSV" do
      deck = create(:deck, user: default_user, name: "My Deck")
      login_as(default_user)

      post_replace(deck, "foo,bar\n1,2\n")

      expect(rendered).to have_text("Replace cards in My Deck")
    end

    it "sets an error flash on invalid CSV" do
      login_as(default_user)

      post_replace(create(:deck, user: default_user), "foo,bar\n1,2\n")

      expect(flash.now[:error])
        .to include("must include 'front' and 'back' columns")
    end

    it "returns not found for another user's deck" do
      login_as(default_user)

      post_replace(create(:deck, user: create(:user)), valid_csv)

      expect(response).to have_http_status(:not_found)
    end

    it "blocks music decks" do
      deck = create(:music_deck, user: default_user)
      login_as(default_user)

      post_replace(deck, valid_csv)

      expect(response).to redirect_to(deck_path(deck))
    end
  end
end
