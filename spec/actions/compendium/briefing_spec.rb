# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Briefing do
  def use(sense, **)
    tokens = [{ "text" => "花", "sense_id" => sense.id }, { "text" => "。" }]

    create(:snippet_sentence, body: "花。", tokens:, **)
  end

  def briefing(*senses) = described_class.call(senses.map(&:entry))
  def entries_of(entry) = described_class.call([entry])[:headwords].sole

  def sense_of(sense)
    briefing(sense)[:headwords].sole[:entries].sole[:senses].sole
  end

  def capitals
    ["o", "a"].map do |article|
      create(:entry, language: "pt", headword: "capital", article:)
    end
  end

  describe ".call" do
    it "groups entries sharing a headword" do
      expect(described_class.call(capitals)[:headwords].sole[:entries].size)
        .to eq(2)
    end

    it "gives an entry's term and reading" do
      entry = create(:entry, headword: "花", reading: "huā")

      expect(entries_of(entry)[:entries])
        .to eq([{ id: entry.id, term: "花", reading: "huā", senses: [] }])
    end

    it "gives a noun's term with its article" do
      entry = create(:entry, language: "pt", headword: "casa", article: "a")

      expect(entries_of(entry)[:entries])
        .to eq([{ id: entry.id, term: "a casa", senses: [] }])
    end

    it "gives a sense's gloss and traditional form" do
      sense = create(:sense, gloss: "flower", traditional: "花")

      expect(sense_of(sense)).to include(gloss: "flower", traditional: "花")
    end

    it "gives a sense's examples" do
      sense = create(:sense)
      create(:sense_example, sense:, sentence: "花开了", translation: "bloom")

      expect(sense_of(sense))
        .to include(examples: [{ sentence: "花开了", translation: "bloom" }])
    end

    it "gives each list once" do
      list = create(:word_list, name: "HSK 3")
      memberships = create_list(:sense_membership, 2, word_list: list)

      expect(briefing(*memberships.map(&:sense)))
        .to include(lists: [{ lid: 0, name: "HSK 3" }])
    end

    it "points a sense at the lists that hold it, with its category" do
      membership = create(:sense_membership, category: "noun")

      expect(sense_of(membership.sense))
        .to include(lists: [{ lid: 0, category: "noun" }])
    end

    it "gives each sentence once, with its source" do
      senses = create_list(:sense, 2)
      tokens = senses.map { |sense| { "text" => "花", "sense_id" => sense.id } }
      sentence = create(:snippet_sentence, body: "花花", tokens:)

      expect(briefing(*senses)[:sentences])
        .to eq([{ sid: 0, source_id: sentence.source_id, text: "花花" }])
    end

    it "gives the sentences either side of a use" do
      sense = create(:sense)
      snippet = create(:snippet)
      use(sense, snippet:, position: 1)
      create(:snippet_sentence, snippet:, position: 0, body: "前。")

      expect(briefing(sense)[:sentences].sole).to include(before: "前。")
    end

    it "gives a source's title alone, since it is in no snippet" do
      sense = create(:sense)
      tokens = [{ "text" => "花", "sense_id" => sense.id }]
      create(:front_matter, body: "花", tokens:)

      expect(briefing(sense)[:sentences].sole.keys)
        .to eq([:sid, :source_id, :text])
    end

    it "points a sense at the tokens that use it" do
      sense = create(:sense)
      use(sense)

      expect(sense_of(sense)).to include(uses: [{ sid: 0, tokens: [0] }])
    end

    it "samples a common sense's uses and counts them all" do
      sense = create(:sense)
      (described_class::USES + 1).times { use(sense) }

      expect(sense_of(sense))
        .to include(uses: have_attributes(size: 5), use_count: 6)
    end
  end
end
