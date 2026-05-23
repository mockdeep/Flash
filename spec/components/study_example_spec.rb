# frozen_string_literal: true

require "rails_helper"

RSpec.describe Components::StudyExample do
  def render_for(card)
    described_class.new(card:).call
  end

  it "always renders the wrapper div with the expected id" do
    html = render_for(build(:card))

    expect(html).to include(%(id="study-example"))
  end

  it "renders both example texts when present" do
    attrs = { example_front: "Bonjour le monde", example_back: "Hello world" }
    card = build(:card, **attrs)

    expect(render_for(card)).to include(*attrs.values)
  end

  it "renders an empty wrapper when both example fields are blank" do
    html = render_for(build(:card))

    expect(html).to eq(%(<div id="study-example"></div>))
  end

  it "renders an empty wrapper when only example_front is present" do
    card = build(:card, example_front: "Bonjour", example_back: nil)

    expect(render_for(card)).to eq(%(<div id="study-example"></div>))
  end

  it "renders an empty wrapper when only example_back is present" do
    card = build(:card, example_front: nil, example_back: "Hello")

    expect(render_for(card)).to eq(%(<div id="study-example"></div>))
  end

  it "html-escapes the example content" do
    payload = "<script>alert(1)</script>"
    card = build(:card, example_front: payload, example_back: "safe")

    expect(render_for(card)).not_to include("<script>")
  end
end
