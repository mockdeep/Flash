# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Categorize do
  def membership(headword: "爱", gloss: "to love")
    entry = create(:entry, headword:, reading: "ài")

    create(:sense_membership, sense: create(:sense, entry:, gloss:))
  end

  def categories(*names)
    rows = names.each_with_index.map { |category, id| { id:, category: } }

    { categories: rows }
  end

  describe ".call" do
    it "asks nothing when there are no memberships" do
      expect(described_class.call([])).to eq([])
    end

    it "asks Sonnet" do
      llm.answer(categories("verb"))

      described_class.call([membership])

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "asks about each word by its headword, reading and gloss" do
      llm.answer(categories("verb"))
      prompt = [{ id: 0, headword: "爱", reading: "ài", gloss: "to love" }]

      described_class.call([membership])

      expect(llm.calls.sole.prompt).to eq(prompt.to_json)
    end

    it "files each membership under its answer" do
      filed = [membership, membership(headword: "花", gloss: "flower")]
      llm.answer(categories("verb", "noun"))

      described_class.call(filed)

      expect(filed.map(&:category)).to eq(["verb", "noun"])
    end

    it "files a membership the answer leaves out under other" do
      unanswered = membership
      llm.answer(categories)

      expect { described_class.call([unanswered]) }
        .to change_record(unanswered, :category).to("other")
    end

    it "files an answer without a category under other" do
      bare = membership
      llm.answer({ categories: [{ id: 0 }] })

      expect { described_class.call([bare]) }
        .to change_record(bare, :category).to("other")
    end
  end
end
