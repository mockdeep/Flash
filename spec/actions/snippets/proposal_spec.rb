# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Proposal do
  def occurrence(word = "爱")
    tokens = [{ "text" => word }]
    sentence = build(:snippet_sentence, body: word, tokens:)
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
        .to eq("a new sense needs both a reading and a gloss")
    end

    it "asks for a gloss on a new sense without one" do
      expect(proposal("new", reading: "ài").problem)
        .to eq("a new sense needs both a reading and a gloss")
    end
  end

  describe "#proposed" do
    it "is the headword, reading and gloss put before the judge" do
      expect(proposal("new", reading: "ài", gloss: "to love").proposed)
        .to eq(headword: "爱", reading: "ài", gloss: "to love")
    end
  end
end
