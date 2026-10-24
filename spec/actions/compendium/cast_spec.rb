# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Cast do
  def note(name)
    { narrator: "none", characters: [{ name:, gender: "male", about: "" }] }
  end

  def prompt(call) = JSON.parse(call.prompt)

  describe ".call" do
    it "is nil for a source with no finished snippet" do
      source = create(:snippet).source

      expect(described_class.call(source)).to be_nil
    end

    it "asks Sonnet" do
      llm.answer(note("Louis"))

      described_class.call(create(:snippet, :finished).source)

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "gives the source's title and author" do
      llm.answer(note("Louis"))
      source = create(:source, title: "Entrevista", author: "Anne Rice")

      described_class.call(create(:snippet, :finished, source:).source)

      expect(prompt(llm.calls.sole)["source"])
        .to eq("title" => "Entrevista", "author" => "Anne Rice")
    end

    it "gives the snippet's heading and body" do
      llm.answer(note("Louis"))
      snippet = create(:snippet, :finished, heading: "Parte Um", body: "Ele")

      described_class.call(snippet.source)

      expect(prompt(llm.calls.sole)["snippet"])
        .to eq("heading" => "Parte Um", "body" => "Ele")
    end

    it "starts with no note" do
      llm.answer(note("Louis"))

      described_class.call(create(:snippet, :finished).source)

      expect(prompt(llm.calls.sole)).to include("note" => nil)
    end

    it "hands each snippet the note so far" do
      llm.answer(note("Louis"), note("Lestat"))
      source = create(:source)
      create_list(:snippet, 2, :finished, source:)

      described_class.call(source)

      expect(prompt(llm.calls.last)["note"]).to eq(note("Louis").as_json)
    end

    it "gives the note after the last snippet" do
      llm.answer(note("Louis"), note("Lestat"))
      source = create(:source)
      create_list(:snippet, 2, :finished, source:)

      expect(described_class.call(source)).to eq(note("Lestat").as_json)
    end

    it "leaves out snippets that are not finished" do
      llm.answer(note("Louis"))
      source = create(:snippet).source
      create(:snippet, :finished, source:)

      described_class.call(source)

      expect(llm.calls.size).to eq(1)
    end
  end
end
