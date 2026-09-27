# frozen_string_literal: true

RSpec.describe "the deck-creation form" do
  def visit_new_deck
    sign_in(default_user)
    visit(new_deck_path)
    expect(page).to have_text("Create New Deck")
  end

  # Language decks are not creatable: their content comes from the catalog,
  # and a freeform CSV upload is a Basic deck.
  it "offers no Language deck type" do
    visit_new_deck

    expect(page).to have_no_field("Language", visible: :all)
  end

  it "offers Basic" do
    visit_new_deck

    expect(page).to have_field("Basic", visible: :all)
  end

  it "offers Music" do
    visit_new_deck

    expect(page).to have_field("Music (microphone required)", visible: :all)
  end
end
