# frozen_string_literal: true

RSpec.describe "deck sharing" do
  def owner_deck
    owner = create(:user, password: "super-secure")
    deck = create(:deck, user: owner, name: "My Spanish Deck")
    create(:card, deck:, front: "hola", back: "hello", category: "greetings")
    deck
  end

  def visit_deck_as_owner(deck)
    sign_in(deck.user)
    visit(deck_path(deck))
  end

  def visit_deck_with_confirm_stub(deck)
    visit_deck_as_owner(deck)
    page.execute_script("window.confirm = () => true")
  end

  def visit_active_shared_deck_as(user)
    deck = owner_deck.tap(&:generate_share_token!)
    sign_in(user)
    visit(shared_deck_path(deck.share_token))
    deck
  end

  def expect_share_active(deck)
    expect(page).to have_button("Copy")
    expect(page).to have_field(
      type: "text",
      with: %r{/shared/#{deck.reload.share_token}\z},
    )
  end

  it "lets the owner generate a share link" do
    deck = owner_deck
    visit_deck_as_owner(deck)

    click_on("Share Link")

    expect_share_active(deck)
  end

  it "lets the owner revoke an active share link" do
    deck = owner_deck.tap(&:generate_share_token!)
    visit_deck_with_confirm_stub(deck)

    click_on("Revoke Link")

    expect(page).to have_flash(:success, "Share link revoked")
    expect(deck.reload.share_token).to be_nil
  end

  it "lets an unauthenticated visitor preview a shared deck" do
    deck = owner_deck.tap(&:generate_share_token!)

    visit(shared_deck_path(deck.share_token))

    expect(page).to have_text("shared by #{deck.user.username}")
    expect(page).to have_button("Try This Deck")
  end

  it "lets an unauthenticated visitor try a shared deck as a guest" do
    deck = owner_deck.tap(&:generate_share_token!)
    visit(shared_deck_path(deck.share_token))

    click_on("Try This Deck")

    expect(page).to have_css(".demo-banner")
    expect(User.last.role).to eq("guest")
  end

  it "lets a signed-in visitor add a shared deck to their account" do
    friend = create(:user, password: "super-secure")
    deck = visit_active_shared_deck_as(friend)

    click_on("Add to My Decks")

    expect(page).to have_flash(:success, "Deck copied successfully")
    expect(friend.decks.pluck(:name)).to include(deck.name)
  end
end
