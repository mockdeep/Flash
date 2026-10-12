# frozen_string_literal: true

RSpec.describe Components::DeckTexts, type: :view do
  def render_for(deck)
    Capybara.string(view.render(described_class.new(deck:)))
  end

  def deck_with(**source_attributes)
    deck = create(:reading_deck)
    create(:source, word_list: deck.word_list, **source_attributes)
    create(:snippet, :finished, word_list: deck.word_list)
    deck
  end

  it "renders nothing without a finished snippet" do
    deck = create(:reading_deck)
    create(:snippet, word_list: deck.word_list)

    expect(render_for(deck)).to have_no_css(".catalog-preview")
  end

  it "shows the source's title" do
    page = render_for(deck_with(title: "筷子"))

    expect(page).to have_css("td", text: "筷子")
  end

  it "shows the source's author" do
    page = render_for(deck_with(author: "鲁迅"))

    expect(page).to have_css("td", text: "鲁迅")
  end

  it "links an included source's license to its terms" do
    page = render_for(deck_with(license: "cc_by_sa"))
    url = "https://creativecommons.org/licenses/by-sa/4.0/"

    expect(page).to have_link("CC BY-SA 4.0", href: url)
  end

  it "marks a source its license keeps from sharing" do
    page = render_for(deck_with)

    expect(page).to have_css("td", text: "Not included — words only")
  end

  it "points to the Read tab when the source is included" do
    page = render_for(deck_with(license: "public_domain"))

    expect(page).to have_text("on the deck's Read tab")
  end

  it "leaves out the Read tab when the source is not included" do
    page = render_for(deck_with)

    expect(page).to have_no_text("Read tab")
  end
end
