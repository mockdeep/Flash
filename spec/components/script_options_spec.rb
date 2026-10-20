# frozen_string_literal: true

RSpec.describe Components::ScriptOptions, type: :view do
  def render_options(deck)
    Capybara.string(view.render(described_class.new(deck:)))
  end

  it "offers each script" do
    page = render_options(create(:reading_deck))

    expect(page.all("button").map(&:text))
      .to eq(["简Simplified", "繁Traditional"])
  end

  it "marks the deck's script as chosen" do
    page = render_options(create(:reading_deck, script: "traditional"))

    expect(page).to have_css("button[aria-checked=true]", text: "Traditional")
  end

  it "saves the script to the deck" do
    deck = create(:reading_deck)

    expect(render_options(deck))
      .to have_css("form[action='#{deck_script_path(deck)}']", count: 2)
  end

  it "reloads the whole page, Read tab and all" do
    page = render_options(create(:reading_deck))

    expect(page).to have_css("form[data-turbo-frame=_top]", count: 2)
  end
end
