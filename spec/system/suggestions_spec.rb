# frozen_string_literal: true

RSpec.describe "reviewing suggestions" do
  def build_deck_with_suggestion
    deck = build_catalog_deck
    card = create(:card, deck:, front: "Old Q", back: "Old A", category: "Geo")
    suggestion = create_suggestion(card)
    [deck, card, suggestion]
  end

  def build_catalog_deck
    create(:deck, user: default_user, visibility: "public", name: "Geo")
  end

  def create_suggestion(card)
    create(
      :card_suggestion,
      card:,
      user: create(:user, username: "alice"),
      front: "Better Q",
      back: "Better A",
      category: "Geography",
    )
  end

  def visit_suggestions_for(deck)
    sign_in(default_user)
    visit(deck_suggestions_path(deck))
    page.execute_script("window.confirm = () => true")
  end

  it "shows the suggestion attribution" do
    deck, _card, _suggestion = build_deck_with_suggestion

    visit_suggestions_for(deck)

    expect(page).to have_text("Suggested by alice")
  end

  it "shows the current card values" do
    deck, _card, _suggestion = build_deck_with_suggestion

    visit_suggestions_for(deck)

    expect(page).to(have_text("Old Q").and(have_text("Old A")))
  end

  it "shows the proposed values" do
    deck, _card, _suggestion = build_deck_with_suggestion

    visit_suggestions_for(deck)

    expect(page).to(have_text("Better Q").and(have_text("Better A")))
  end

  it "applies the suggestion when the owner accepts" do
    deck, card, _suggestion = build_deck_with_suggestion
    visit_suggestions_for(deck)

    click_on("Accept")

    expect(CardContent.new(card.reload).front).to eq("Better Q")
  end

  it "removes the suggestion from the page after accepting" do
    deck, _card, _suggestion = build_deck_with_suggestion
    visit_suggestions_for(deck)

    click_on("Accept")

    expect(page).to have_text("No pending suggestions")
  end

  it "marks the suggestion rejected without changing the card" do
    deck, card, suggestion = build_deck_with_suggestion
    visit_suggestions_for(deck)

    click_on("Reject")

    expect(CardContent.new(card.reload).front).to eq("Old Q")
    expect(suggestion.reload.state).to eq("rejected")
  end

  it "shows an empty state when no suggestions are pending" do
    deck = create(:deck, user: default_user, visibility: "public")
    visit_suggestions_for(deck)

    expect(page).to have_text("No pending suggestions")
  end
end
