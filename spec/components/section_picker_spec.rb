# frozen_string_literal: true

RSpec.describe Components::SectionPicker, type: :view do
  def render_picker(deck)
    Capybara.string(view.render(described_class.new(deck:)))
  end

  # A deck for the first of a source's two finished sections, "Parte Um".
  def deck_over_sections
    first = create(:snippet, :finished, heading: "Parte Um")
    create(:snippet, :finished, word_list: first.word_list)
    create(:reading_deck, word_list: first.word_list, snippet: first)
  end

  it "offers each finished section by its label" do
    page = render_picker(deck_over_sections)

    expect(page.all("button", visible: :all).map(&:text))
      .to eq(["Parte Um", "2"])
  end

  it "leaves out a section not yet processed" do
    deck = deck_over_sections
    create(:snippet, word_list: deck.word_list)

    expect(render_picker(deck)).to have_button(count: 2, visible: :all)
  end

  it "opens the picked section's deck" do
    deck = deck_over_sections
    action = "form[action='#{deck_section_path(deck)}']"

    expect(render_picker(deck)).to have_css(action, count: 2, visible: :all)
  end

  it "names the deck's own section" do
    expect(render_picker(deck_over_sections))
      .to have_css("summary", text: "Section: Parte Um")
  end

  it "marks the deck's own section" do
    expect(render_picker(deck_over_sections))
      .to have_css("button[aria-current=true]", text: "Parte Um", visible: :all)
  end

  it "renders nothing for a source with one section" do
    snippet = create(:snippet, :finished)
    deck = create(:reading_deck, word_list: snippet.word_list, snippet:)

    expect(view.render(described_class.new(deck:))).to be_empty
  end
end
