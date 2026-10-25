# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Categorize do
  def categorize(memberships)
    described_class.call(memberships, Language::MANDARIN)
  end

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
      expect(categorize([])).to eq([])
    end

    it "asks Sonnet" do
      llm.answer(categories("verb"))

      categorize([membership])

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "asks about each word by its headword, reading and gloss" do
      llm.answer(categories("verb"))
      prompt = [{ id: 0, headword: "爱", reading: "ài", gloss: "to love" }]

      categorize([membership])

      expect(llm.calls.sole.prompt).to eq(prompt.to_json)
    end

    it "asks about a noun with its article" do
      llm.answer(categories("noun"))
      filed = membership
      filed.sense.entry.update!(language: "pt", article: "o")

      categorize([filed])

      expect(llm.calls.sole.prompt).to include('"headword":"o 爱"')
    end

    it "files each membership under its answer" do
      filed = [membership, membership(headword: "花", gloss: "flower")]
      llm.answer(categories("verb", "noun"))

      categorize(filed)

      expect(filed.map(&:category)).to eq(["verb", "noun"])
    end

    it "files a membership the answer leaves out under other" do
      unanswered = membership
      llm.answer(categories)

      expect { categorize([unanswered]) }
        .to change_record(unanswered, :category).to("other")
    end

    it "files an answer without a category under other" do
      bare = membership
      llm.answer({ categories: [{ id: 0 }] })

      expect { categorize([bare]) }
        .to change_record(bare, :category).to("other")
    end
  end
end
