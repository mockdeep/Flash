# frozen_string_literal: true

RSpec.describe CatalogSourcesController do
  # A listed source with one finished section, owned by someone else.
  def listed_source
    owner = create(:user)
    word_list = create(:word_list, user: owner)
    snippet = create(:snippet, :finished, word_list:)
    create(:source_listing, source: snippet.source).source
  end

  describe "#show" do
    it "renders without authentication" do
      get(catalog_source_path(listed_source))

      expect(response).to have_http_status(:ok)
    end

    it "previews the list's cards" do
      source = listed_source
      create(:language_card, deck: source.preview_deck, front: "爱")

      get(catalog_source_path(source))

      expect(rendered).to have_css(".catalog-preview td", text: "爱")
    end

    it "is not found for a source not listed" do
      get(catalog_source_path(create(:source)))

      expect(response).to have_http_status(:not_found)
    end

    it "offers to add the source" do
      login_as(default_user)
      source = listed_source

      get(catalog_source_path(source))

      expect(rendered).to have_button("Add to My Decks")
    end

    it "lets a member who has it study it" do
      login_as(default_user)
      source = listed_source
      deck = default_user.deck_starting(source)

      get(catalog_source_path(source))

      expect(rendered).to have_link(href: deck_study_path(deck))
    end

    it "offers a visitor a try" do
      source = listed_source

      get(catalog_source_path(source))

      expect(rendered)
        .to have_css("form[action='#{try_catalog_source_path(source)}']")
    end
  end

  describe "#copy" do
    it "makes the member's deck for the first section" do
      login_as(default_user)
      source = listed_source

      post(copy_catalog_source_path(source))

      expect(default_user.decks.last.snippet).to eq(source.first_section)
    end

    it "goes to the member's decks" do
      login_as(default_user)

      post(copy_catalog_source_path(listed_source))

      expect(response).to redirect_to(decks_path)
    end
  end

  describe "#try" do
    def try_source(source)
      post(try_catalog_source_path(source), params: { time_zone: "UTC" })
    end

    it "starts a guest at the first section" do
      source = listed_source

      try_source(source)

      expect(Deck.last).to have_attributes(snippet: source.first_section)
    end

    it "opens the guest's deck" do
      try_source(listed_source)

      expect(response).to redirect_to(deck_study_path(Deck.last))
    end
  end
end
