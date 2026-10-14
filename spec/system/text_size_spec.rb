# frozen_string_literal: true

RSpec.describe "study text size" do
  def visit_study_page
    deck = create(:deck, user: default_user)
    create_list(:basic_card, 5, deck:)
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

    expect(page).to have_css(".study-page[data-size='l']")
  end

  it "increments the size when the ] hotkey is pressed" do
    visit_study_page

    find("body").send_keys("]")

    expect(page).to have_css(".study-page[data-size='l']")
  end

  def visit_read_tab
    word_list = create(:word_list, user: default_user)
    deck = create(:reading_deck, user: default_user, word_list:)
    create(:language_card, deck:)
    snippet = create(:snippet, source: create(:source, word_list:))
    tokens = [{ "text" => "我", "sense_id" => create(:sense).id }]
    create(:snippet_sentence, snippet:, body: "我", tokens:)
    sign_in(default_user)
    visit(deck_study_path(deck))
    choose("Read", allow_label_click: true)
  end

  it "changes the size with the ] hotkey on the Read tab" do
    visit_read_tab

    find("body").send_keys("]")

    expect(page).to have_css(".study-page[data-size='l']")
  end

  it "persists the selected size across page reloads" do
    deck = visit_study_page
    open_size_menu
    pick_size("xl")

    visit(deck_study_path(deck))

    expect(page).to have_css(".study-page[data-size='xl']")
  end
end
