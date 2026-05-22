# frozen_string_literal: true

RSpec.describe "finding pending suggestions" do
  def seed_pending_for(deck)
    card = create(:card, deck:)
    create(:card_suggestion, card:)
  end

  def own_deck(name: "Geography")
    create(:deck, user: default_user, name:)
  end

  def visit_decks_signed_in(**params)
    sign_in(default_user)
    visit(decks_path(**params))
  end

  it "shows a dot on the Decks nav link when there are pending suggestions" do
    seed_pending_for(own_deck)

    visit_decks_signed_in

    expect(page).to have_css(".nav-link .nav-link-dot")
  end

  it "hides the nav dot when there are no pending suggestions" do
    own_deck

    visit_decks_signed_in

    expect(page).to have_text("Your Decks")
    expect(page).to have_no_css(".nav-link-dot")
  end

  it "shows a per-deck badge with the pending suggestion count" do
    deck = own_deck(name: "Hot Deck")
    2.times { seed_pending_for(deck) }

    visit_decks_signed_in

    expect(page).to have_text("2 pending suggestions")
  end

  it "navigates to the deck's suggestions page when the badge is clicked" do
    seed_pending_for(own_deck(name: "Hot Deck"))
    visit_decks_signed_in

    click_on("1 pending suggestions")

    expect(page).to have_text("Suggestions for Hot Deck")
  end

  it "filters the decks index to only decks with pending suggestions" do
    seed_pending_for(own_deck(name: "Hot Deck"))
    own_deck(name: "Cold Deck")
    visit_decks_signed_in

    click_on("Show only decks with pending suggestions")

    expect(page).to(have_text("Hot Deck").and(have_no_text("Cold Deck")))
  end

  it "clears the filter when the active chip is clicked" do
    seed_pending_for(own_deck(name: "Hot Deck"))
    own_deck(name: "Cold Deck")
    visit_decks_signed_in(filter: "pending_suggestions")
    click_on("Show all decks")

    expect(page).to have_text("Cold Deck")
  end
end
