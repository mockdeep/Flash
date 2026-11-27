# frozen_string_literal: true

RSpec.describe ReadingPages do
  def snippet_with(body, language: "zh", heading: nil)
    source = create(:source, word_list: create(:word_list, language:))
    snippet = create(:snippet, source:, body:, heading:)
    sentence(snippet, heading, position: 0, role: "heading") if heading
    lines = Snippets::SplitSentences.call(body, snippet.language)
    lines.each.with_index(1) do |line, position|
      sentence(snippet, line, position:)
    end
    snippet.reload
  end

  # Its tokens split as the text writes them: a Han character or a word, and
  # each mark on its own.
  def sentence(snippet, body, **)
    texts = body.scan(/\p{Han}|[\p{L}\p{N}]+|[^\s\p{L}\p{N}]/)
    tokens = texts.map { { "text" => it } }
    create(:snippet_sentence, snippet:, body:, tokens:, **)
  end

  def pages_of(*snippets, language: "zh")
    described_class.new(snippets:, language: Language.for(language))
  end

  def portuguese_pages(body)
    pages_of(snippet_with(body, language: "pt"), language: "pt")
  end

  def texts(page)
    page.lines.map { |line| line.tokens.pluck("text").join }
  end

  it "gives each snippet its own page" do
    pages = pages_of(snippet_with("我。"), snippet_with("你。"))

    expect(pages.map { texts(it) }).to eq([["我。"], ["你。"]])
  end

  it "keeps a short snippet on one page" do
    pages = pages_of(snippet_with("我爱你。\n他爱我。"))

    expect(pages.size).to eq(1)
  end

  it "breaks before the character that would pass the length" do
    stub_const("ReadingPages::CHARACTERS", 3)
    pages = pages_of(snippet_with("我爱你。他爱我。"))

    expect(pages.map { texts(it) }).to eq([["我爱你。"], ["他爱我。"]])
  end

  it "breaks in the middle of a sentence" do
    stub_const("ReadingPages::CHARACTERS", 2)
    pages = pages_of(snippet_with("我爱你。"))

    expect(pages.map { texts(it) }).to eq([["我爱"], ["你。"]])
  end

  it "keeps a line carried over in its kind" do
    stub_const("ReadingPages::CHARACTERS", 1)
    pages = pages_of(snippet_with("我爱。", heading: "春节"))

    expect(pages.page(2).lines.map(&:tag)).to eq([:h3])
  end

  it "opens a snippet's first page with its heading" do
    pages = pages_of(snippet_with("我。", heading: "春节"))

    expect(pages.first.lines.map(&:tag)).to eq([:h3, :p])
  end

  it "takes an opening quote over to the word it opens" do
    stub_const("ReadingPages::CHARACTERS", 1)
    pages = pages_of(snippet_with("我“你”"))

    expect(texts(pages.page(2))).to eq(["“你”"])
  end

  it "counts words in a language written with spaces" do
    stub_const("ReadingPages::WORDS", 2)
    pages = portuguese_pages("A casa é minha.")

    expect(pages.map { texts(it) }).to eq([["A casa "], ["é minha."]])
  end

  # A sentence whose tokens are just its words, as a segmenter may leave
  # its punctuation out.
  def bare_words(body)
    snippet = create(:snippet, body:)
    tokens = body.scan(/\p{L}+/).map { { "text" => it } }
    create(:snippet_sentence, snippet:, body:, tokens:)
    pages_of(snippet.reload, language: "pt")
  end

  it "takes over an opening quote the tokens leave out" do
    stub_const("ReadingPages::WORDS", 1)
    pages = bare_words("Sim. “Não.”")

    expect(pages.map { texts(it) }).to eq([["Sim. "], ["“Não.”"]])
  end

  it "opens no page on a space" do
    stub_const("ReadingPages::WORDS", 1)
    pages = portuguese_pages("Sim. Não.")

    expect(texts(pages.page(2))).to eq(["Não."])
  end

  it "starts a page at its first token" do
    stub_const("ReadingPages::CHARACTERS", 2)
    snippet = snippet_with("我爱你。")

    sentence_id = snippet.sentences.first.id
    expect(pages_of(snippet).page(2).start)
      .to eq(described_class::Start.new(sentence_id:, index: 2))
  end

  it "finds the page holding a token" do
    stub_const("ReadingPages::CHARACTERS", 2)
    snippet = snippet_with("我爱你。")
    pages = pages_of(snippet)

    expect(pages.at(snippet.sentences.first.id.to_s, "3").number).to eq(2)
  end

  it "opens on the first page without a place" do
    pages = pages_of(snippet_with("我。"))

    expect(pages.at(nil, nil).number).to eq(1)
  end

  it "opens on the first page for a token it doesn't hold" do
    pages = pages_of(snippet_with("我。"))

    expect(pages.at(0, 0).number).to eq(1)
  end

  it "has no page before the first" do
    pages = pages_of(snippet_with("我。"))

    expect(pages.page(0)).to be_nil
  end

  it "makes no page of a snippet with no sentences" do
    snippet = create(:snippet, body: "我。")

    expect(pages_of(snippet).size).to eq(0)
  end

  it "has no text for a deck with no source" do
    deck = create(:deck)

    expect(described_class.for(deck).size).to eq(0)
  end
end
