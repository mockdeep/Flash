# frozen_string_literal: true

RSpec.describe Components::SourceCredit, type: :view do
  def render_for(source)
    Capybara.string(view.render(described_class.new(source:)))
  end

  it "links to where the source came from" do
    url = "https://zh.wikipedia.org/zh-cn/春节"
    page = render_for(build(:source, source_url: url))

    expect(page).to have_link("Source", href: url)
  end

  it "leaves out the link when the source has none" do
    page = render_for(build(:source))

    expect(page).to have_no_link("Source")
  end

  it "names the license" do
    page = render_for(build(:source, license: "public_domain"))

    expect(page).to have_text("Public domain")
  end
end
