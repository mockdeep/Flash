# frozen_string_literal: true

RSpec.describe "organizing decks into topics" do
  def deck_named(name)
    deck = create(:deck, name:, user: default_user)
    create(:card, deck:)
    deck
  end

  def mandarin_deck
    topic = create(:topic, name: "Mandarin", user: default_user)
    deck_named("HSK 1").tap { |deck| deck.data_set.update!(topic:) }
  end

  def visit_deck(deck)
    sign_in(default_user)
    visit(deck_path(deck))
  end

  it "assigns a deck to a new topic from the deck page" do
    visit_deck(deck_named("HSK 1"))
    fill_in("Topic", with: "Mandarin")
    click_on("Add to topic")

    expect(page).to have_text("Added to the Mandarin topic")
    expect(page).to have_text("Topic: Mandarin")
  end

  it "groups decks under their topic on the index" do
    mandarin_deck
    sign_in(default_user)

    visit(decks_path)

    expect(page).to have_css("h2", text: "Mandarin")
  end

  it "lists un-topiced decks under Other Decks on the index" do
    mandarin_deck
    deck_named("US Capitals")
    sign_in(default_user)

    visit(decks_path)

    expect(page).to have_css("h2", text: "Other Decks")
  end

  it "removes a deck from its topic" do
    visit_deck(mandarin_deck)
    click_on("Remove from topic")

    expect(page).to have_text("Removed from topic")
    expect(page).to have_button("Add to topic")
  end
end
