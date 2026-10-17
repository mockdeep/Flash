# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Report do
  def love(gloss: "to love")
    create(:sense, entry: create(:entry, headword: "爱", reading: "ài"), gloss:)
  end

  def report(*tokens, title: "Love")
    snippet = create(:snippet, source: create(:source, title:))
    create(:snippet_sentence, snippet:, body: "我爱你。", tokens:)
    described_class.call(snippet)
  end

  def resolved(sense, outcome = "matched")
    { "text" => "爱", "outcome" => outcome, "sense_id" => sense.id }
  end

  describe ".call" do
    it "sums the snippet up" do
      expect(report(resolved(love), title: "Love"))
        .to match(/\ASnippet \d+ "Love" \(list .+\): in_progress, 1 matched$/)
    end

    it "shows the source title's translation" do
      source = create(:source, title: "春节", title_translation: "Spring")
      snippet = create(:snippet, source:)

      expect(described_class.call(snippet))
        .to include("Translations:\n  source #{source.id} title 春节: Spring")
    end

    it "flags a missing heading translation" do
      snippet = create(:snippet, heading: "习俗")

      expect(described_class.call(snippet))
        .to include("  snippet #{snippet.id} heading 习俗: missing")
    end

    it "leaves out the heading line when there is no heading" do
      snippet = create(:snippet, heading: nil)

      expect(described_class.call(snippet)).not_to include("heading")
    end

    it "lists the unresolved words with their reasons" do
      token = { "text" => "爱", "outcome" => "unresolved", "note" => "?" }

      expect(report(token))
        .to match(/Unresolved:\n  sentence \d+ token 0 爱: \?/)
    end

    it "shows a noun with its article" do
      entry = create(
        :entry, language: "pt", headword: "casa", reading: nil, article: "a"
      )
      sense = create(:sense, entry:, gloss: "house")

      expect(report(resolved(sense))).to include("##{sense.id} a casa: house")
    end

    it "lists the senses the snippet created" do
      sense = love

      expect(report(resolved(sense, "created")))
        .to include("Created:\n  ##{sense.id} 爱 ài: to love")
    end

    it "shows each sentence token by token" do
      sense = love

      expect(report(resolved(sense), { "text" => "。" }))
        .to include("  0 爱 → ##{sense.id} 爱 ài: to love [matched]\n  1 。")
    end

    it "shows a finished token without an outcome" do
      sense = love

      expect(report({ "text" => "爱", "sense_id" => sense.id }))
        .to end_with("  0 爱 → ##{sense.id} 爱 ài: to love")
    end

    it "lists the skipped words with their reasons" do
      token = { "text" => "爱", "skip" => "foreign" }

      expect(report(token))
        .to match(/Skipped:\n  sentence \d+ token 0 爱: foreign/)
    end

    it "shows a skipped word" do
      expect(report({ "text" => "爱", "skip" => "foreign" }))
        .to end_with("  0 爱: skipped (foreign)")
    end

    it "shows a sense without a reading" do
      entry = create(:entry, language: "pt", headword: "casa", reading: nil)
      sense = create(:sense, entry:, gloss: "house")

      expect(report(resolved(sense))).to include("##{sense.id} casa: house")
    end

    it "shows a word not yet resolved" do
      expect(report({ "text" => "爱" })).to end_with("  0 爱: not resolved yet")
    end
  end

  describe ".unused" do
    it "lists senses no list holds and no token points at" do
      sense = love

      expect(described_class.unused)
        .to eq("Unused senses:\n  ##{sense.id} 爱 ài: to love")
    end

    it "leaves out senses a token points at" do
      report(resolved(love))

      expect(described_class.unused).to eq("")
    end

    it "leaves out senses a list holds" do
      create(:sense_membership)

      expect(described_class.unused).to eq("")
    end
  end
end
