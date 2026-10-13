# frozen_string_literal: true

RSpec.describe Components::SnippetReading, type: :view do
  def render_for(*snippets, level: 1, source: create(:source))
    deck = create(:reading_deck, level:, word_list: source.word_list)
    Capybara.string(view.render(described_class.new(snippets:, deck:)))
  end

  def render_text(...)
    Capybara.string(render_for(...).native.to_html.gsub(%r{<rt>.*?</rt>}, ""))
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

  def portuguese_snippet(level: 1)
    source = create(:source, word_list: create(:word_list, language: "pt"))
    entry = create(:entry, language: "pt", headword: "casa", reading: nil)
    sense = create(:sense, entry:, gloss: "house")
    snippet = create(:snippet, source:, body: "A casa.")
    tokens = [{ "text" => "A" }, { "text" => "casa", "sense_id" => sense.id }]
    create(:snippet_sentence, snippet:, tokens:)
    render_for(snippet, level:, source:)
  end

  def love_snippet
    snippet_with("我爱。", [word("我", "wǒ"), word("爱", "ài"), { "text" => "。" }])
  end

  def two_line_snippet
    words = [word("我", "wǒ"), word("你", "nǐ"), word("他", "tā")]
    snippet_with("我。\n\n你。他。", *words.map { |w| [w, { "text" => "。" }] })
  end

  it "shows the source's title" do
    page = render_for(source: create(:source, title: "春节"))

    expect(page).to have_css("h2", text: "春节")
  end

  it "shows each snippet's heading in order" do
    page = render_for(*["第一", "第二"].map { build(:snippet, heading: it) })

    expect(texts_of(page, ".reading-snippet h3")).to eq(["第一", "第二"])
  end

  it "leaves out the heading when there is none" do
    page = render_for(build(:snippet, heading: ""))

    expect(page).to have_no_css(".reading-snippet h3")
  end

  it "shows the author when there is one" do
    page = render_for(source: create(:source, author: "鲁迅"))

    expect(page).to have_css(".reading-snippets__author", text: "鲁迅")
  end

  it "leaves out the author when there is none" do
    page = render_for(source: create(:source, author: ""))

    expect(page).to have_no_css(".reading-snippets__author")
  end

  it "credits the source" do
    page = render_for(source: create(:source, license: "public_domain"))

    expect(page).to have_css(".reading-snippets__credit", text: "Public domain")
  end

  it "shows each line of the body as its own paragraph" do
    page = render_text(two_line_snippet, level: 3)

    paragraphs = texts_of(page, ".reading-snippet p:not([class])")

    expect(paragraphs).to eq(["我。", "你。他。"])
  end

  def render_scored(level: 1, **score)
    snippet = snippet_with("爱。", [word("爱", "ài")])
    create(:skill_score, sense: Sense.sole, **score) if score.any?
    render_for(snippet, level:)
  end

  it "gives each word its reading at any level" do
    page = render_for(love_snippet, level: 3)

    expect(texts_of(page, "rt")).to eq(["wǒ", "ài"])
  end

  it "marks a word never studied as new" do
    page = render_scored

    expect(page).to have_css(".reading-snippet__word--new")
  end

  it "marks a word studied but never seen as new" do
    page = render_scored(view_count: 0)

    expect(page).to have_css(".reading-snippet__word--new")
  end

  it "marks a word with no streak as missed" do
    page = render_scored(view_count: 1, correct_streak: 0)

    expect(page).to have_css(".reading-snippet__word--missed")
  end

  it "marks a word whose streak reaches the deck's level as done" do
    page = render_scored(level: 2, view_count: 2, correct_streak: 2)

    expect(page).to have_css(".reading-snippet__word--done")
  end

  it "leaves a word short of the deck's level unmarked" do
    page = render_scored(level: 2, view_count: 1, correct_streak: 1)

    word = page.find("button")
    expect(word[:class]).to eq("reading-snippet__word")
  end

  it "reads only the deck owner's scores" do
    user = create(:user)
    page = render_scored(user:, view_count: 1, correct_streak: 1)

    expect(page).to have_css(".reading-snippet__word--new")
  end

  it "marks each word apart" do
    page = render_text(love_snippet, level: 2)

    expect(texts_of(page, "ruby")).to eq(["我", "爱"])
  end

  it "leaves punctuation out of the words" do
    page = render_text(love_snippet, level: 3)

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

  it "keeps the spaces of a text written with them" do
    page = portuguese_snippet(level: 3)

    expect(page).to have_css("p", exact_text: "A casa.")
  end

  it "shows no readings in a language without them" do
    page = portuguese_snippet

    expect(page).to have_no_css(".reading-snippets--readings")
  end

  it "widens the spaces of a text written with them" do
    page = portuguese_snippet

    expect(page).to have_css(".reading-snippets--spaced")
  end

  it "marks no breaks in a text written with spaces" do
    page = portuguese_snippet

    expect(page).to have_no_css("wbr")
  end

  it "shows only the gloss in a language without readings" do
    page = portuguese_snippet

    expect(page).to have_no_css(".reading-snippet__lookup-reading")
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
    page = render_for(love_snippet)

    url = "/decks/#{Deck.sole.id}/lookups"
    expect(page).to have_css("[data-lookup-url-value='#{url}']")
  end
end
