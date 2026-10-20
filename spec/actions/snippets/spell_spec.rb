# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Spell do
  def smoke(traditional: "煙")
    entry = create(:entry, headword: "烟", reading: "yān")
    create(:sense, entry:, gloss: "smoke", traditional:)
  end

  # A token written in traditional, as the segmenter leaves it.
  def written(text, sense)
    { "text" => text, "headword" => "烟", "sense_id" => sense.id }
  end

  def snippet_with(*tokens)
    snippet = create(:snippet)
    create(
      :snippet_sentence,
      snippet:,
      body: tokens.pluck("text").join,
      tokens:,
    )
    snippet
  end

  def spelled_sense(snippet)
    described_class.call(snippet)
    Sense.find(snippet.sentences.sole.reload.tokens.sole["sense_id"])
  end

  describe ".call" do
    it "gives a guessed spelling the text's" do
      sense = smoke
      described_class.call(snippet_with(written("菸", sense)))

      expect(sense.reload.traditional).to eq("菸")
    end

    it "keeps a sense spelled as the text spells it" do
      sense = smoke

      expect(spelled_sense(snippet_with(written("煙", sense)))).to eq(sense)
    end

    it "keeps a spelling another text has used" do
      sense = smoke
      snippet_with({ "text" => "煙", "sense_id" => sense.id })
      described_class.call(snippet_with(written("菸", sense)))

      expect(sense.reload.traditional).to eq("煙")
    end

    it "moves the token to a sibling spelled as the text spells it" do
      sense = smoke
      snippet_with({ "text" => "煙", "sense_id" => sense.id })
      sibling = spelled_sense(snippet_with(written("菸", sense)))

      expect([sibling.entry, sibling.gloss, sibling.traditional])
        .to eq([sense.entry, "smoke", "菸"])
    end

    it "keeps two spellings of one text apart" do
      sense = smoke
      snippet = snippet_with(written("菸", sense), written("煙", sense))
      described_class.call(snippet)

      expect(snippet.sentences.sole.reload.tokens.pluck("sense_id").uniq.size)
        .to eq(2)
    end

    it "does not count a spelling that is also the simplified form as used" do
      sense = smoke(traditional: "烟")
      snippet_with({ "text" => "烟", "sense_id" => sense.id })
      described_class.call(snippet_with(written("菸", sense)))

      expect(sense.reload.traditional).to eq("菸")
    end

    it "leaves a token without a sense as it is" do
      snippet = snippet_with(written("菸", smoke), { "text" => "。" })
      described_class.call(snippet)

      expect(snippet.sentences.sole.reload.tokens.last).to eq("text" => "。")
    end

    it "leaves a snippet in simplified alone" do
      sense = smoke
      snippet = snippet_with({ "text" => "烟", "sense_id" => sense.id })
      described_class.call(snippet)

      expect(sense.reload.traditional).to eq("煙")
    end

    it "leaves a Portuguese snippet alone" do
      word_list = create(:word_list, language: "pt")
      snippet = create(:snippet, word_list:)
      tokens = [{ "text" => "Ela", "headword" => "ela", "sense_id" => 1 }]
      create(:snippet_sentence, snippet:, body: "Ela", tokens:)

      expect { described_class.call(snippet) }.not_to raise_error
    end
  end
end
