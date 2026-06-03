# frozen_string_literal: true

RSpec.describe Components::CardReading do
  def render_for(reading)
    described_class.new(reading:).call
  end

  it "always renders the wrapper div with the expected id" do
    expect(render_for(nil)).to include(%(id="card-reading"))
  end

  it "renders the reading when present" do
    expect(render_for("liǎng")).to include("liǎng")
  end

  it "renders an empty wrapper when the reading is blank" do
    expect(render_for(nil))
      .to eq(%(<div id="card-reading" class="card-reading"></div>))
  end

  it "html-escapes the reading content" do
    expect(render_for("<script>alert(1)</script>")).not_to include("<script>")
  end
end
