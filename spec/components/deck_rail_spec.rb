# frozen_string_literal: true

RSpec.describe Components::DeckRail, type: :view do
  def render_for(decks, &)
    deck_section = DeckSection.new(name: "Basic", decks:)
    Capybara.string(view.render(described_class.new(deck_section:), &))
  end

  it "names the section" do
    expect(render_for(Deck.none)).to have_css("h2", text: "Basic")
  end

  it "gives the section an anchor" do
    expect(render_for(Deck.none)).to have_css("section#basic")
  end

  it "links the heading to its anchor" do
    expect(render_for(Deck.none)).to have_link("Basic", href: "#basic")
  end

  it "counts the section's decks" do
    create(:deck)

    expect(render_for(Deck.all)).to have_css(".section-meta", text: "1 deck")
  end

  it "fills the rail from the block" do
    page = render_for(Deck.none) { "the cards" }

    expect(page).to have_css(".rail", text: "the cards")
  end

  it "renders hidden scroll arrows" do
    page = render_for(Deck.none)

    expect(page).to have_css(".rail-arrow[hidden]", visible: :all, count: 2)
  end
end
