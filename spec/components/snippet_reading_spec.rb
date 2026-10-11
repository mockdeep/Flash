# frozen_string_literal: true

RSpec.describe Components::SnippetReading do
  def render_for(*snippets, level: 1)
    Capybara.string(described_class.new(snippets:, level:).call)
  end

  def texts_of(page, selector) = page.all(selector).map(&:text)

  def word(text, reading)
    sense = create(:sense, entry: create(:entry, headword: text, reading:))
    { "text" => text, "sense_id" => sense.id }
  end

  def snippet_with(body, *token_lists)
    snippet = create(:snippet, body:)
    token_lists.each.with_index do |tokens, position|
      create(:snippet_sentence, snippet:, position:, tokens:)
    end
    snippet
  end

  def love_snippet
    snippet_with("我爱。", [word("我", "wǒ"), word("爱", "ài"), { "text" => "。" }])
  end

  def two_line_snippet
    words = [word("我", "wǒ"), word("你", "nǐ"), word("他", "tā")]
    snippet_with("我。\n\n你。他。", *words.map { |w| [w, { "text" => "。" }] })
  end

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
    page = render_for(two_line_snippet, level: 3)

    expect(texts_of(page, ".reading-snippet p")).to eq(["我。", "你。他。"])
  end

  it "shows each word's reading at level 1" do
    page = render_for(love_snippet, level: 1)

    expect(texts_of(page, "rt")).to eq(["wǒ", "ài"])
  end

  it "leaves out the readings above level 1" do
    page = render_for(love_snippet, level: 2)

    expect(page).to have_no_css("rt")
  end

  it "marks each word apart" do
    page = render_for(love_snippet, level: 2)

    expect(texts_of(page, "ruby")).to eq(["我", "爱"])
  end

  it "leaves punctuation out of the words" do
    page = render_for(love_snippet, level: 3)

    expect(page).to have_css("p", exact_text: "我爱。")
  end

  it "spaces the words up to level 2" do
    page = render_for(love_snippet, level: 2)

    expect(page).to have_css(".reading-snippets--gaps")
  end

  it "runs the words together above level 2" do
    page = render_for(love_snippet, level: 3)

    expect(page).to have_no_css(".reading-snippets--gaps")
  end
end
