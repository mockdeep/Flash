# frozen_string_literal: true

RSpec.describe "deck deletion" do
  def owner_deck
    owner = create(:user, password: "super-secure")
    deck = create(:deck, user: owner, name: "My Spanish Deck")
    create(
      :basic_card,
      deck:,
      front: "hola",
      back: "hello",
      category: "greetings",
    )
    deck
  end

  def visit_deck_with_confirm_stub(deck)
    sign_in(deck.user)
    visit(deck_path(deck))
    page.execute_script("window.confirm = () => true")
  end

  it "lets the owner delete a deck from the show page" do
    deck = owner_deck
    visit_deck_with_confirm_stub(deck)

    click_on("Delete Deck")

    expect(page).to have_flash(:success, "Deck deleted")
    expect(Deck.exists?(deck.id)).to be(false)
  end
end
