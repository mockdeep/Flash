# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::StudyExample do
  def render_for(front, back)
    card = build(:basic_card)
    card.item = build(:item, example: front, paired_example: back)
    described_class.new(card:).call
  end

  it "always renders the wrapper div with the expected id" do
    expect(render_for(nil, nil)).to include(%(id="study-example"))
  end

  it "renders both example texts when present" do
    html = render_for("Bonjour le monde", "Hello world")

    expect(html).to include("Bonjour le monde", "Hello world")
  end

  it "renders a toggle bound to the x hotkey" do
    html = render_for("Bonjour le monde", "Hello world")

    expect(html).to include("study-example__toggle", %(data-hotkey="x"))
  end

  it "renders the panel hidden" do
    html = render_for("Bonjour le monde", "Hello world")

    expect(html).to include(%(class="study-example" hidden))
  end

  it "renders an empty wrapper when both example fields are blank" do
    expect(render_for(nil, nil)).to eq(%(<div id="study-example"></div>))
  end

  it "renders an empty wrapper when only example_front is present" do
    expect(render_for("Bonjour", nil)).to eq(%(<div id="study-example"></div>))
  end

  it "renders an empty wrapper when only example_back is present" do
    expect(render_for(nil, "Hello")).to eq(%(<div id="study-example"></div>))
  end

  it "html-escapes the example content" do
    html = render_for("<script>alert(1)</script>", "safe")

    expect(html).not_to include("<script>")
  end
end
