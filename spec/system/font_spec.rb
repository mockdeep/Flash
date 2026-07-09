# frozen_string_literal: true

RSpec.describe "study font" do
  def hanzi_cards
    {
      "他" => "he; him",
      "你" => "you",
      "我" => "I; me",
      "好" => "good",
      "水" => "water",
    }
  end

  def visit_hanzi_study_page
    deck = create(:deck, user: default_user, language: "zh")
    hanzi_cards.each { |front, back| create(:card, deck:, front:, back:) }
    sign_in(default_user)
    visit(deck_study_path(deck))
    deck
  end

  def visit_latin_study_page
    deck = create(:deck, user: default_user)
    create_list(:card, 5, deck:)
    sign_in(default_user)
    visit(deck_study_path(deck))
    deck
  end

  def open_card_menu
    click_on("Card options")
  end

  def pick_font(font)
    within(".card-front__menu") { find("[data-font='#{font}']").click }
  end

  it "applies the hei default on a hanzi deck" do
    visit_hanzi_study_page

    expect(page).to have_css(".study-frame[data-font='hei']")
  end

  it "applies a font picked from the kebab menu" do
    visit_hanzi_study_page
    open_card_menu

    pick_font("kai")

    expect(page).to have_css(".study-frame[data-font='kai']")
  end

  it "persists the selected font across page reloads" do
    deck = visit_hanzi_study_page
    open_card_menu
    pick_font("song")

    visit(deck_study_path(deck))

    expect(page).to have_css(".study-frame[data-font='song']")
  end

  def pick_mix_and_read_font
    open_card_menu
    pick_font("mix")
    find(".study-frame")["data-font"]
  end

  it "keeps the mixed font while answering a card" do
    visit_hanzi_study_page
    asked = pick_mix_and_read_font

    first(".answer-button").click

    expect(page).to have_css(".study-frame[data-font='#{asked}'] .answer-row")
  end

  it "omits the font section on a deck without hanzi", :aggregate_failures do
    visit_latin_study_page
    open_card_menu

    expect(page).to have_css(".card-front__menu", text: /text size/i)
    expect(page).to have_no_css(".card-front__menu [data-font]", visible: :all)
  end

  it "does not tag the study frame with a font on a deck without hanzi" do
    visit_latin_study_page

    expect(page).to have_css(".study-frame")
    expect(page).to have_no_css(".study-frame[data-font]")
  end
end
