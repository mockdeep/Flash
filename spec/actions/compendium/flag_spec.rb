# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Flag do
  def suggestion
    {
      headword: "mal",
      problem: "category",
      reason: "a particle",
      examples: [],
      confidence: "medium",
      edits: [{ action: "recategorize", sense: "1", list_id: 2 }],
    }
  end

  describe ".call" do
    it "asks Sonnet" do
      llm.answer(suggestions: [])

      described_class.call({ headwords: [] }, language: "de")

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "asks under the language's flag prompt" do
      llm.answer(suggestions: [])

      described_class.call({ headwords: [] }, language: "zh")

      expect(llm.calls.sole.system).to eq(Compendium::RefinePrompts.flag("zh"))
    end

    it "sends the prompt as JSON" do
      llm.answer(suggestions: [])

      described_class.call({ headwords: [] }, language: "de")

      expect(llm.calls.sole.prompt).to eq('{"headwords":[]}')
    end

    it "returns the suggestions" do
      llm.answer(suggestions: [suggestion])

      expect(described_class.call({ headwords: [] }, language: "de"))
        .to eq([suggestion.as_json])
    end
  end
end
