# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::RecordSpellings do
  def snippet_in(language, *tokens)
    snippet = create(:snippet, word_list: create(:word_list, language:))
    create(:snippet_sentence, snippet:, tokens:)
    snippet
  end

  def siya(language: "fil")
    create(:sense, entry: create(:entry, language:, headword: "siya"))
  end

  def token(sense, text = "Sya") = { "text" => text, "sense_id" => sense.id }

  it "records a spelling that differs from its headword" do
    sense = siya
    described_class.call(snippet_in("fil", token(sense)))

    expect(sense.entry.spellings.sole.text).to eq("sya")
  end

  it "records a repeated spelling once" do
    sense = siya
    described_class.call(snippet_in("fil", token(sense), token(sense)))

    expect(sense.entry.spellings.count).to eq(1)
  end

  it "leaves out a word spelled as its headword" do
    sense = siya
    described_class.call(snippet_in("fil", token(sense, "Siya")))

    expect(sense.entry.spellings).to be_empty
  end

  it "leaves out a token without a sense" do
    described_class.call(snippet_in("fil", { "text" => "." }))

    expect(Spelling.count).to eq(0)
  end

  it "leaves a language that doesn't respell alone" do
    sense = siya(language: "pt")
    described_class.call(snippet_in("pt", token(sense)))

    expect(sense.entry.spellings).to be_empty
  end
end
