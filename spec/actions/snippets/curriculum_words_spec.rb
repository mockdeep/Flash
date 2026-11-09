# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::CurriculumWords do
  def listed(headword, traditional: nil, curriculum: true, language: "zh")
    list = create(:word_list, curriculum:, language:)
    entry = create(:entry, headword:, language:)
    sense = create(:sense, entry:, traditional:)
    create(:sense_membership, sense:, word_list: list)
  end

  def found_in(text, language = Language::MANDARIN)
    described_class.for(language).found_in(text)
  end

  describe ".for" do
    it "finds a word of a curriculum list in the text" do
      listed("东西")

      expect(found_in("买东西")).to eq(["东西"])
    end

    it "leaves out a word only other lists hold" do
      listed("东西", curriculum: false)

      expect(found_in("买东西")).to be_empty
    end

    it "finds a word in its traditional form" do
      listed("东西", traditional: "東西")

      expect(found_in("買東西")).to eq(["東西"])
    end

    it "leaves out a single character" do
      listed("买")

      expect(found_in("买东西")).to be_empty
    end

    it "leaves out another language's curriculum" do
      listed("casa", language: "pt")

      expect(found_in("casa")).to be_empty
    end
  end

  describe "#found_in" do
    it "lists the words in the order the text first writes them" do
      words = described_class.new(["天上", "东西", "上东"])

      expect(words.found_in("天上东西东西")).to eq(["天上", "上东", "东西"])
    end

    it "finds a word at the very end of the text" do
      words = described_class.new(["东西"])

      expect(words.found_in("买东西")).to eq(["东西"])
    end

    it "finds nothing in a text with no curriculum words" do
      words = described_class.new([])

      expect(words.found_in("买东西")).to be_empty
    end
  end
end
