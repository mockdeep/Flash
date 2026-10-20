# frozen_string_literal: true

RSpec.describe Components::CardMenu, type: :view do
  def render_menu(deck: create(:deck))
    view.render(described_class.new(deck:))
  end

  def mandarin_menu = render_menu(deck: create(:reading_deck))

  it "renders the toggle wired to the disclosure controller" do
    expect(render_menu).to include(%(data-action="click->disclosure#toggle"))
  end

  it "renders a size option for each size" do
    html = render_menu

    described_class::SIZES.each_key do |code|
      expect(html).to include(%(data-size="#{code}"))
    end
  end

  it "closes the menu when a size option is picked" do
    expect(render_menu).to include("click->disclosure#close")
  end

  it "omits the font section outside Mandarin" do
    expect(render_menu).not_to include("data-font")
  end

  it "omits the characters section outside Mandarin" do
    expect(render_menu).not_to include("Characters")
  end

  it "shows the characters section on a Mandarin deck" do
    expect(mandarin_menu).to include("Characters")
  end

  it "renders a font option for each font on a Mandarin deck" do
    html = mandarin_menu

    described_class::FONTS.each_key do |code|
      expect(html).to include(%(data-font="#{code}"))
    end
  end

  it "labels the font section" do
    expect(mandarin_menu).to include("Font")
  end

  it "previews font options with a hanzi letter" do
    expect(mandarin_menu).to include("汉")
  end

  it "wires font options to the font controller and menu close" do
    expect(mandarin_menu)
      .to include(%(data-action="click->font#setFont click->disclosure#close"))
  end
end
