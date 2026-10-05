# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Review do
  def sentence_with(*tokens) = create(:snippet_sentence, tokens:)

  def unresolved(text = "爱", **rest)
    { "text" => text, "outcome" => "unresolved", "note" => "wrong tone" }
      .merge(rest.stringify_keys)
  end

  describe ".repoint" do
    it "points the token at the sense" do
      sense = create(:sense)
      sentence = sentence_with(unresolved)
      described_class.repoint(sentence, 0, sense)

      expect(sentence.reload.tokens.sole["sense_id"]).to eq(sense.id)
    end

    it "clears the note the token carried" do
      sentence = sentence_with(unresolved)
      described_class.repoint(sentence, 0, create(:sense))

      expect(sentence.reload.tokens.sole).not_to have_key("note")
    end

    it "leaves the other tokens alone" do
      sentence = sentence_with(unresolved, { "text" => "。" })
      described_class.repoint(sentence, 0, create(:sense))

      expect(sentence.reload.tokens.last).to eq("text" => "。")
    end
  end

  describe ".add_sense" do
    def add(sentence, gloss: "to love", reading: "ài")
      described_class.add_sense(sentence, 0, reading:, gloss:)
    end

    it "creates the sense under the token's headword" do
      add(sentence_with(unresolved("愛", simplified: "爱")))

      expect(Sense.last.entry.headword).to eq("爱")
    end

    it "points the token at the sense" do
      sentence = sentence_with(unresolved)
      sense = add(sentence)

      expect(sentence.reload.tokens.sole["sense_id"]).to eq(sense.id)
    end
  end

  describe ".resegment" do
    def segmented_as(*words)
      words = words.map { |word| { text: word, simplified: word } }
      { sentences: [{ id: 0, words: }] }
    end

    it "segments the sentence again with the complaint" do
      llm.answer(segmented_as("花", "了"), *[{ decisions: [] }] * 4)
      sentence = create(:snippet_sentence, body: "花了", tokens: [unresolved])
      described_class.resegment(sentence, "split 花 and 了")

      expect(llm.calls.first.prompt).to include("split 花 and 了")
    end

    it "resolves the new tokens" do
      llm.answer(segmented_as("花", "了"), *[{ decisions: [] }] * 4)
      sentence = create(:snippet_sentence, body: "花了", tokens: [unresolved])
      described_class.resegment(sentence, "split 花 and 了")

      expect(sentence.reload.tokens.pluck("outcome")).to all(eq("unresolved"))
    end
  end
end
