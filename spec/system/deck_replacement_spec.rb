# frozen_string_literal: true

RSpec.describe "deck replacement" do
  def owner_deck
    owner = create(:user, password: "super-secure")
    deck = create(:deck, user: owner, name: "Trivia")
    seed_card(deck, "What is 2+2?", "4")
    seed_card(deck, "What is the capital of France?", "London")
    seed_card(deck, "Old card", "Old")
    deck
  end

  def seed_card(deck, front, back)
    create(:card, deck:, front:, back:)
  end

  def start_replacement
    deck = owner_deck
    sign_in(deck.user)
    visit(new_deck_replacement_path(deck))
    expect(page).to have_text("Replace cards in Trivia")
    attach_basic_csv
  end

  def attach_basic_csv
    attach_file(
      "Flashcards CSV File",
      "spec/fixtures/files/decks/basic.csv",
      make_visible: true,
    )
  end

  def summary_flash
    "Replaced cards: 1 added, 1 removed, 1 reset, 1 kept"
  end

  it "replaces the cards in a deck via the upload form" do
    start_replacement

    accept_confirm { click_on("Replace Cards") }

    expect(page).to have_flash(:success, summary_flash)
  end

  it "shows the new card list after replacement" do
    start_replacement

    accept_confirm { click_on("Replace Cards") }

    expect(page).to have_text("Who wrote Romeo and Juliet?")
  end

  it "removes cards that were dropped from the new CSV" do
    start_replacement

    accept_confirm { click_on("Replace Cards") }

    expect(page).to have_no_text("Old card")
  end

  it "keeps the user on the form when they cancel the confirmation" do
    start_replacement

    dismiss_confirm { click_on("Replace Cards") }

    expect(page).to have_text("Replace cards in Trivia")
  end
end
