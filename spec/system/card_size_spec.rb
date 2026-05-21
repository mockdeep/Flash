# frozen_string_literal: true

RSpec.describe "card-front text size" do
  def visit_study_page
    deck = create(:deck, user: default_user)
    create_list(:card, 5, deck:)
    sign_in(default_user)
    visit(deck_study_path(deck))
    deck
  end

  def open_size_menu
    click_on("Card options")
  end

  def pick_size(size)
    within(".card-front__menu") { find("[data-size='#{size}']").click }
  end

  it "applies a size picked from the kebab menu" do
    visit_study_page
    open_size_menu

    pick_size("l")

    expect(page).to have_css(".card-front-wrapper[data-size='l']")
  end

  it "increments the size when the ] hotkey is pressed" do
    visit_study_page

    find("body").send_keys("]")

    expect(page).to have_css(".card-front-wrapper[data-size='l']")
  end

  it "persists the selected size across page reloads" do
    deck = visit_study_page
    open_size_menu
    pick_size("xl")

    visit(deck_study_path(deck))

    expect(page).to have_css(".card-front-wrapper[data-size='xl']")
  end
end
