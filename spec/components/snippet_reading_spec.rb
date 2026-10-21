# frozen_string_literal: true

RSpec.describe Components::SnippetReading, type: :view do
  def render_for(*snippets, source: create(:source), **deck_attributes)
    word_list = source.word_list
    deck = create(:reading_deck, word_list:, **deck_attributes)
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

  def portuguese_snippet(round: 1, article: nil)
    source = create(:source, word_list: create(:word_list, language: "pt"))
    entry =
      create(:entry, language: "pt", headword: "casa", reading: nil, article:)
    sense = create(:sense, entry:, gloss: "house")
    snippet = create(:snippet, source:, body: "A casa.")
    tokens = [{ "text" => "A" }, { "text" => "casa", "sense_id" => sense.id }]
    create(:snippet_sentence, snippet:, tokens:)
    render_for(snippet, round:, source:)
  end

  def body_snippet(script:, traditional: "體")
    entry = create(:entry, headword: "体", reading: "tǐ")
    sense = create(:sense, entry:, gloss: "body", traditional:)
    tokens = [{ "text" => "體", "sense_id" => sense.id }]
    render_text(snippet_with("體", tokens), script:)
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

  it "translates the source's title" do
    page = render_for(source: create(:source, title_translation: "Spring"))

    expect(page).to have_css("h2 .translation", text: "Spring")
  end

  it "translates a snippet's heading" do
    snippet = build(:snippet, heading: "第一", heading_translation: "First")
    page = render_for(snippet)

    expect(page).to have_css("h3 .translation", text: "First")
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
    page = render_text(two_line_snippet, round: 3)

    paragraphs = texts_of(page, ".reading-snippet p:not([class])")

    expect(paragraphs).to eq(["我。", "你。他。"])
  end

  def render_scored(round: 1, **score)
    snippet = snippet_with("爱。", [word("爱", "ài")])
    create(:skill_score, sense: Sense.sole, **score) if score.any?
    render_for(snippet, round:)
  end

  it "gives each word its reading at any round" do
    page = render_for(love_snippet, round: 3)

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

  it "marks a word whose streak reaches the deck's round as done" do
    page = render_scored(round: 2, view_count: 2, correct_streak: 2)

    expect(page).to have_css(".reading-snippet__word--done")
  end

  it "marks a done word's popover done" do
    page = render_scored(round: 2, view_count: 2, correct_streak: 2)

    expect(page).to have_css("[popover].reading-snippet__lookup--done")
  end

  it "leaves the popover of a word part way there not done" do
    page = render_scored(round: 2, view_count: 2, correct_streak: 1)

    expect(page).to have_no_css(".reading-snippet__lookup--done")
  end

  it "leaves a word short of the deck's round unmarked" do
    page = render_scored(round: 2, view_count: 1, correct_streak: 1)

    word = page.find(".reading-snippet__word")
    expect(word[:class]).to eq("reading-snippet__word")
  end

  it "reads only the deck owner's scores" do
    user = create(:user)
    page = render_scored(user:, view_count: 1, correct_streak: 1)

    expect(page).to have_css(".reading-snippet__word--new")
  end

  it "marks each word apart" do
    page = render_text(love_snippet, round: 2)

    expect(texts_of(page, "ruby")).to eq(["我", "爱"])
  end

  it "leaves punctuation out of the words" do
    page = render_text(love_snippet, round: 3)

    expect(page).to have_css("p", exact_text: "我爱。")
  end

  it "spaces the words up to round 2" do
    page = render_for(love_snippet, round: 2)

    expect(page).to have_css(".reading-snippets--gaps")
  end

  it "runs the words together above round 2" do
    page = render_for(love_snippet, round: 3)

    expect(page).to have_no_css(".reading-snippets--gaps")
  end

  it "keeps the spaces of a text written with them" do
    page = portuguese_snippet(round: 3)

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

    expect(page).to have_no_css(".reading-snippet__lookup-label")
  end

  it "shows a noun with its article over the gloss" do
    page = portuguese_snippet(article: "a")

    expect(page).to have_css(".reading-snippet__lookup-label", text: "a casa")
  end

  def abbreviated_snippet
    source = create(:source, word_list: create(:word_list, language: "pt"))
    entry = create(:entry, language: "pt", headword: "Dona", reading: nil)
    sense = create(:sense, entry:, gloss: "Ms.")
    snippet = create(:snippet, source:, body: "D.")
    tokens = [{ "text" => "D.", "sense_id" => sense.id }]
    create(:snippet_sentence, snippet:, tokens:)
    render_for(snippet, source:)
  end

  it "keeps an abbreviation as written in the text" do
    page = abbreviated_snippet

    expect(page).to have_css(".reading-snippet__word", text: "D.")
  end

  it "shows an abbreviation written out over the gloss" do
    page = abbreviated_snippet

    expect(page).to have_css(".reading-snippet__lookup-label", text: "Dona")
  end

  def skipped_snippet(skip)
    source = create(:source, word_list: create(:word_list, language: "pt"))
    snippet = create(:snippet, source:, body: "Inácia.")
    create(:snippet_sentence, snippet:, tokens: [{ "text" => "Inácia", skip: }])
    render_for(snippet, source:)
  end

  it "says a skipped name is a name" do
    page = skipped_snippet("name")

    expect(page).to have_css("[popover]", exact_text: "name")
  end

  it "says a skipped foreign title is one" do
    page = skipped_snippet("foreign")

    expect(page).to have_css("[popover]", text: "title in another language")
  end

  it "opens a skipped word's popover from the word" do
    page = skipped_snippet("name")

    target = page.find("button")[:popovertarget]
    expect(target).to eq(page.find("[popover]")[:id])
  end

  it "gives a skipped word no state" do
    page = skipped_snippet("name")

    expect(page.find("button")[:class]).to eq("reading-snippet__word")
  end

  it "offers no restudy for a skipped word" do
    page = skipped_snippet("name")

    expect(page).to have_no_css(".reading-snippet__restudy")
  end

  it "records nothing for a skipped word" do
    page = skipped_snippet("name")

    expect(page).to have_no_css("button[data-action]")
  end

  it "shows each word's reading and gloss in its popover" do
    page = render_for(snippet_with("爱。", [word("爱", "ài", gloss: "love")]))

    expect(page).to have_css("[popover]", text: "àilove")
  end

  it "opens the word's own popover from the word" do
    page = render_for(love_snippet)

    targets = page.all(".reading-snippet__word").pluck("popovertarget")
    expect(targets).to eq(page.all("[popover]").pluck("id"))
  end

  it "passes the word's sense to its restudy button" do
    snippet = snippet_with("爱。", [word("爱", "ài")])
    page = render_for(snippet)

    sense_id = snippet.sentences.first.tokens.first["sense_id"]
    restudy = page.find(".reading-snippet__restudy")
    expect(restudy["data-miss-sense-id-param"]).to eq(sense_id.to_s)
  end

  it "records a view when the word is clicked" do
    page = render_for(snippet_with("爱。", [word("爱", "ài")]))

    word = page.find(".reading-snippet__word")
    expect(word["data-action"]).to eq("miss#view")
  end

  it "passes the word's sense to its view" do
    snippet = snippet_with("爱。", [word("爱", "ài")])
    page = render_for(snippet)

    sense_id = snippet.sentences.first.tokens.first["sense_id"]
    word = page.find(".reading-snippet__word")
    expect(word["data-miss-sense-id-param"]).to eq(sense_id.to_s)
  end

  it "marks the word with its sense" do
    snippet = snippet_with("爱。", [word("爱", "ài")])
    page = render_for(snippet)

    sense_id = snippet.sentences.first.tokens.first["sense_id"]
    word = page.find(".reading-snippet__word")
    expect(word["data-sense-id"]).to eq(sense_id.to_s)
  end

  it "marks the popover with its word's sense" do
    snippet = snippet_with("爱。", [word("爱", "ài")])
    page = render_for(snippet)

    sense_id = snippet.sentences.first.tokens.first["sense_id"]
    expect(page).to have_css("[popover][data-sense-id='#{sense_id}']")
  end

  it "sends misses to the deck" do
    page = render_for(love_snippet)

    url = "/decks/#{Deck.sole.id}/misses"
    expect(page).to have_css("[data-miss-url-value='#{url}']")
  end

  it "writes a word in simplified on a simplified deck" do
    page = body_snippet(script: "simplified")

    expect(page).to have_css(".reading-snippet__word", text: "体")
  end

  it "writes a word in traditional on a traditional deck" do
    page = body_snippet(script: "traditional")

    expect(page).to have_css(".reading-snippet__word", text: "體")
  end

  it "writes a word with no traditional form as its headword" do
    page = body_snippet(script: "traditional", traditional: nil)

    expect(page).to have_css(".reading-snippet__word", text: "体")
  end

  it "keeps a word's text in a language without traditional forms" do
    page = portuguese_snippet

    expect(page).to have_css(".reading-snippet__word", text: "casa")
  end
end
