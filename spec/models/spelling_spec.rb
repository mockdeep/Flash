# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spelling do
  def filipino_entry(headword) = create(:entry, language: "fil", headword:)

  def settled?(text, headword) = described_class.settled?("fil", text, headword)

  it "keeps its text in lower case" do
    spelling = create(:spelling, text: "SYA")

    expect(spelling.text).to eq("sya")
  end

  it "is deleted with its entry" do
    spelling = create(:spelling)

    spelling.entry.destroy!

    expect(described_class.exists?(spelling.id)).to be(false)
  end

  describe ".settled?" do
    it "is true for a spelling of that one word" do
      create(:spelling, entry: filipino_entry("siya"), text: "sya")

      expect(settled?("Sya", "siya")).to be(true)
    end

    it "is false for a spelling not recorded yet" do
      filipino_entry("siya")

      expect(settled?("sya", "siya")).to be(false)
    end

    it "is false for a spelling of another word" do
      create(:spelling, entry: filipino_entry("iyon"), text: "yon")

      expect(settled?("yon", "iyong")).to be(false)
    end

    it "is false for a spelling of two words" do
      create(:spelling, entry: filipino_entry("iyong"), text: "yung")
      create(:spelling, entry: filipino_entry("iyon"), text: "yung")

      expect(settled?("yung", "iyong")).to be(false)
    end

    it "is false for a spelling that is a word of its own" do
      filipino_entry("ng")
      create(:spelling, entry: filipino_entry("nang"), text: "ng")

      expect(settled?("ng", "nang")).to be(false)
    end

    it "keeps to its language" do
      create(:entry, language: "pt", headword: "sya")
      create(:spelling, entry: filipino_entry("siya"), text: "sya")

      expect(settled?("sya", "siya")).to be(true)
    end
  end
end
