# frozen_string_literal: true

RSpec.describe Components::SnippetReading do
  def render_for(*snippets)
    Capybara.string(described_class.new(snippets:).call)
  end

  def texts_of(page, selector) = page.all(selector).map(&:text)

  it "shows each snippet's title in order" do
    page = render_for(*["第一", "第二"].map { |title| build(:snippet, title:) })

    expect(texts_of(page, ".reading-snippet h2")).to eq(["第一", "第二"])
  end

  it "shows the author when there is one" do
    page = render_for(build(:snippet, author: "鲁迅"))

    expect(page).to have_css(".reading-snippet__author", text: "鲁迅")
  end

  it "leaves out the author when there is none" do
    page = render_for(build(:snippet, author: ""))

    expect(page).to have_no_css(".reading-snippet__author")
  end

  it "shows each line of the body as its own paragraph" do
    page = render_for(build(:snippet, body: "我爱你。\n\n你爱我。\r\n他爱她。"))

    expect(texts_of(page, ".reading-snippet p")).to eq(["我爱你。", "你爱我。", "他爱她。"])
  end
end
