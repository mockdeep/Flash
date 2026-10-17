# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Proposal do
  def occurrence(word = "爱")
    tokens = [{ "text" => word }]
    sentence = build(:snippet_sentence, body: word, tokens:)
    Snippets::Occurrence.new(sentence:, index: 0)
  end

  def portuguese
    word_list = create(:word_list, language: "pt")
    snippet = create(:snippet, word_list:)
    sentence = build(
      :snippet_sentence,
      snippet:,
      tokens: [{ "text" => "casa" }],
    )
    Snippets::Occurrence.new(sentence:, index: 0)
  end

  def proposal(decision, occurrence: self.occurrence, **fields)
    row = { sense_id: 0, reading: "", gloss: "", note: "" }
    row = row.merge(decision:, **fields).stringify_keys
    described_class.from(occurrence, row)
  end

  describe "#new_sense?" do
    it "is true for a new decision" do
      expect(proposal("new").new_sense?).to be(true)
    end

    it "is false for an existing decision" do
      expect(proposal("existing").new_sense?).to be(false)
    end
  end

  describe "#headword" do
    it "is the occurrence's headword" do
      expect(proposal("new").headword).to eq("爱")
    end
  end

  describe "#problem" do
    it "is nil for a missegmented token" do
      expect(proposal("missegmented").problem).to be_nil
    end

    it "is nil when an existing sense is one of the word's" do
      sense = create(:sense, entry: create(:entry, headword: "爱"))

      expect(proposal("existing", sense_id: sense.id).problem).to be_nil
    end

    it "names an existing sense that is not one of the word's" do
      sense = create(:sense)

      expect(proposal("existing", sense_id: sense.id).problem)
        .to eq("sense_id #{sense.id} is not one of this word's listed senses")
    end

    it "is nil for a new sense with a reading and a gloss" do
      expect(proposal("new", reading: "ài", gloss: "to love").problem).to be_nil
    end

    it "asks for a reading on a new sense without one" do
      expect(proposal("new", gloss: "to love").problem)
        .to eq("a new sense needs a reading")
    end

    it "asks for a gloss on a new sense without one" do
      expect(proposal("new", reading: "ài").problem)
        .to eq("a new sense needs a gloss")
    end

    it "asks for both on a new sense with neither" do
      expect(proposal("new").problem)
        .to eq("a new sense needs a reading and a gloss")
    end

    it "names the articles allowed on a new sense with another" do
      new_sense =
        proposal("new", occurrence: portuguese, gloss: "house", article: "la")

      expect(new_sense.problem).to eq("the article must be one of o, a, os, as")
    end

    it "takes a new sense with an allowed article" do
      new_sense =
        proposal("new", occurrence: portuguese, gloss: "house", article: "a")

      expect(new_sense.problem).to be_nil
    end

    it "takes a gloss alone in a language without readings" do
      expect(proposal("new", occurrence: portuguese, gloss: "house").problem)
        .to be_nil
    end
  end

  describe "#sense_reading" do
    it "is the proposed reading" do
      expect(proposal("new", reading: "ài").sense_reading).to eq("ài")
    end

    it "is nil in a language without readings" do
      new_sense = proposal("new", occurrence: portuguese, reading: "ˈka.zɐ")

      expect(new_sense.sense_reading).to be_nil
    end
  end

  describe "#sense_article" do
    it "is the proposed article" do
      new_sense = proposal("new", occurrence: portuguese, article: "a")

      expect(new_sense.sense_article).to eq("a")
    end

    it "is nil in a language without articles" do
      expect(proposal("new", article: "a").sense_article).to be_nil
    end
  end

  describe "#proposed" do
    it "is the headword, reading and gloss put before the judge" do
      expect(proposal("new", reading: "ài", gloss: "to love").proposed)
        .to eq(headword: "爱", reading: "ài", gloss: "to love")
    end

    it "puts a noun's article before the judge" do
      new_sense =
        proposal("new", occurrence: portuguese, gloss: "house", article: "a")

      expect(new_sense.proposed)
        .to eq(headword: "casa", article: "a", gloss: "house")
    end

    it "puts no reading before the judge in a language without readings" do
      new_sense = proposal("new", occurrence: portuguese, gloss: "house")

      expect(new_sense.proposed).to eq(headword: "casa", gloss: "house")
    end
  end
end
