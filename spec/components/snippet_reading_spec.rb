# frozen_string_literal: true

RSpec.describe Components::SnippetReading, type: :view do
  def render_for(*snippets, level: 1, deck: create(:reading_deck, level:))
    Capybara.string(view.render(described_class.new(snippets:, deck:)))
  end

  def texts_of(page, selector) = page.all(selector).map(&:text)

  def word(text, reading, gloss: "gloss")
    entry = create(:entry, headword: text, reading:)
    sense = create(:sense, entry:, gloss:)
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

  it "shows each word's reading and gloss in its popover" do
    page = render_for(snippet_with("爱。", [word("爱", "ài", gloss: "love")]))

    expect(page).to have_css("[popover]", text: "àilove")
  end

  it "opens the word's own popover from the word" do
    page = render_for(love_snippet)

    targets = page.all("button").pluck("popovertarget")
    expect(targets).to eq(page.all("[popover]").pluck("id"))
  end

  it "passes the word's sense to the lookup" do
    snippet = snippet_with("爱。", [word("爱", "ài")])
    page = render_for(snippet)

    sense_id = snippet.sentences.first.tokens.first["sense_id"]
    expect(page).to have_css("[data-lookup-sense-id-param='#{sense_id}']")
  end

  it "sends lookups to the deck" do
    deck = create(:reading_deck)
    page = render_for(love_snippet, deck:)

    url = "/decks/#{deck.id}/lookups"
    expect(page).to have_css("[data-lookup-url-value='#{url}']")
  end
end
