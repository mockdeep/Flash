# frozen_string_literal: true

RSpec.describe "catalog listings" do
  def admin_deck(**attrs)
    admin = create(:user, :admin, password: "super-secure")
    create(:deck, user: admin, name: "Greek Alphabet", **attrs)
  end

  def visit_deck_as_owner(deck)
    sign_in(deck.user)
    visit(deck_path(deck))
  end

  def visit_deck_with_confirm_stub(deck)
    visit_deck_as_owner(deck)
    page.execute_script("window.confirm = () => true")
  end

  it "lets an admin add their deck to the catalog" do
    deck = admin_deck
    visit_deck_as_owner(deck)

    click_on("Add to Catalog")

    expect(page).to have_flash(:success, "Deck added to catalog")
    expect(page).to have_button("Remove from Catalog")
  end

  it "surfaces the deck in the public catalog after adding" do
    deck = admin_deck
    visit_deck_as_owner(deck)
    click_on("Add to Catalog")

    visit(catalog_index_path)

    expect(page).to have_text(deck.name)
  end

  it "shows the catalog badge on /decks for a public deck" do
    deck = admin_deck(visibility: "public")
    sign_in(deck.user)

    visit(decks_path)

    expect(page).to have_css("[title='In catalog']")
  end

  it "lets an admin remove their deck from the catalog" do
    deck = admin_deck(visibility: "public")
    visit_deck_with_confirm_stub(deck)

    click_on("Remove from Catalog")

    expect(page).to have_flash(:success, "Deck removed from catalog")
    expect(page).to have_button("Add to Catalog")
  end

  it "does not show catalog buttons to a non-admin owner" do
    owner = create(:user, password: "super-secure")
    deck = create(:deck, user: owner, name: "Greek Alphabet")
    visit_deck_as_owner(deck)

    expect(page).to have_text(deck.name)
    expect(page).to have_no_button("Add to Catalog")
  end
end
