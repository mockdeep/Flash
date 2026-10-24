# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Confirm do
  def suggestion(headword) = { "headword" => headword, "problem" => "gloss" }

  def confirm(*suggestions)
    described_class.call(suggestions, prompt: { headwords: [] }, language: "de")
  end

  def verdicts(*rows) = { verdicts: rows }

  describe ".call" do
    it "asks nothing when there are no suggestions" do
      confirm

      expect(llm.calls).to be_empty
    end

    it "asks Opus" do
      llm.answer(verdicts)

      confirm(suggestion("mal"))

      expect(llm.calls.sole.model).to eq("claude-opus-5-5")
    end

    it "sends the batch" do
      llm.answer(verdicts)

      confirm(suggestion("mal"))

      expect(JSON.parse(llm.calls.sole.prompt)).to include("headwords" => [])
    end

    it "numbers each suggestion" do
      llm.answer(verdicts)

      confirm(suggestion("mal"))

      expect(JSON.parse(llm.calls.sole.prompt)["suggestions"])
        .to eq([{ "id" => 0, **suggestion("mal") }])
    end

    it "keeps a suggestion Opus keeps, with its reason" do
      llm.answer(verdicts({ id: 0, keep: true, reason: "a particle" }))

      expect(confirm(suggestion("mal")))
        .to eq([suggestion("mal").merge("confirmed" => "a particle")])
    end

    it "drops a suggestion Opus drops" do
      llm.answer(verdicts({ id: 0, keep: false, reason: "no change" }))

      expect(confirm(suggestion("mal"))).to be_empty
    end

    it "drops a suggestion Opus gives no verdict on" do
      llm.answer(verdicts({ id: 1, keep: true }))

      expect(confirm(suggestion("mal"), suggestion("Tod")))
        .to eq([suggestion("Tod").merge("confirmed" => nil)])
    end
  end
end
