# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Record do
  def occurrence(word, simplified)
    tokens = [{ "text" => word, "simplified" => simplified }.compact]
    sentence = build(:snippet_sentence, body: word, tokens:)
    Snippets::Occurrence.new(sentence:, index: 0)
  end

  def proposal(decision, word: "爱", simplified: nil, **fields)
    row = { sense_id: 0, reading: "ài", gloss: "to love" }
    row = row.merge(decision:, note: "joins two words", **fields)

    Snippets::Proposal.from(occurrence(word, simplified), row.stringify_keys)
  end

  describe ".call" do
    it "leaves a missegmented token unresolved with its note" do
      expect(described_class.call(proposal("missegmented")))
        .to eq("outcome" => "unresolved", "note" => "joins two words")
    end

    it "records an existing sense as matched" do
      sense = create(:sense, entry: create(:entry, headword: "爱"))

      expect(described_class.call(proposal("existing", sense_id: sense.id)))
        .to eq("outcome" => "matched", "sense_id" => sense.id)
    end

    it "records a new sense as created under its new id" do
      result = described_class.call(proposal("new"))

      expect(result).to eq("outcome" => "created", "sense_id" => Sense.last.id)
    end

    it "creates the entry for a new word" do
      described_class.call(proposal("new"))

      expect(Entry.last)
        .to have_attributes(language: "zh", headword: "爱", reading: "ài")
    end

    it "creates the new sense under its gloss" do
      described_class.call(proposal("new"))

      expect(Sense.last.gloss).to eq("to love")
    end

    it "files a traditional word under its simplified headword" do
      described_class.call(proposal("new", word: "愛", simplified: "爱"))

      expect(Entry.last.headword).to eq("爱")
    end

    it "reuses an entry whose reading differs only in punctuation" do
      entry = create(:entry, headword: "可爱", reading: "kě’ài")

      described_class.call(proposal("new", word: "可爱", reading: "kě'ài"))

      expect(Sense.last.entry).to eq(entry)
    end

    it "makes a second entry for another reading of the headword" do
      create(:entry, headword: "还", reading: "hái")
      twin = proposal("new", word: "还", reading: "huán")

      expect { described_class.call(twin) }.to change(Entry, :count).by(1)
    end

    it "reuses a sense the entry already holds under that gloss" do
      entry = create(:entry, headword: "爱", reading: "ài")
      sense = create(:sense, entry:, gloss: "to love")

      expect(described_class.call(proposal("new"))["sense_id"]).to eq(sense.id)
    end

    it "records a reused sense as matched" do
      entry = create(:entry, headword: "爱", reading: "ài")
      create(:sense, entry:, gloss: "to love")

      expect(described_class.call(proposal("new"))["outcome"]).to eq("matched")
    end
  end
end
