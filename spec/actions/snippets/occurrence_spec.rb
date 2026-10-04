# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Occurrence do
  def sentence(words, body: "#{words.join}。")
    tokens = words.map { |word| { "text" => word } }
    build(:snippet_sentence, body:, tokens:)
  end

  def occurrence(words: ["我", "爱", "你"], index: 1)
    described_class.new(sentence: sentence(words), index:)
  end

  describe ".for" do
    it "returns an occurrence per Han token" do
      sentences = [sentence(["我", "爱", "你"])]

      expect(described_class.for(sentences).map(&:word)).to eq(["我", "爱", "你"])
    end

    it "leaves out tokens without a Han character" do
      sentences = [sentence(["我", "，", "OK", "。"], body: "我，OK。")]

      expect(described_class.for(sentences).map(&:word)).to eq(["我"])
    end

    it "gives a word repeated within a sentence an occurrence per token" do
      sentences = [sentence(["花", "钱", "买", "花"])]

      expect(described_class.for(sentences).map(&:index)).to eq([0, 1, 2, 3])
    end

    it "gives a word repeated across sentences an occurrence in each" do
      sentences = [sentence(["我"], body: "我爱你。"), sentence(["我"])]

      expect(described_class.for(sentences).map(&:sentence)).to eq(sentences)
    end
  end

  describe "#word" do
    it "is the text of the token at the index" do
      expect(occurrence.word).to eq("爱")
    end
  end

  describe "#key" do
    it "tells two tokens of one sentence apart" do
      sentence = sentence(["花", "钱", "买", "花"])
      first = described_class.new(sentence:, index: 0)
      last = described_class.new(sentence:, index: 3)

      expect(first.key).not_to eq(last.key)
    end
  end

  describe "#headword" do
    it "is the word when it is already simplified" do
      expect(occurrence.headword).to eq("爱")
    end

    it "is the simplified form the segmenter gave" do
      tokens = [{ "text" => "愛", "simplified" => "爱" }]
      sentence = build(:snippet_sentence, body: "愛", tokens:)

      expect(described_class.new(sentence:, index: 0).headword).to eq("爱")
    end
  end

  describe "#spelling" do
    it "pairs the word with its headword" do
      expect(occurrence.spelling).to eq(["爱", "爱"])
    end
  end

  describe "#senses" do
    it "returns the compendium's senses for the headword" do
      entry = create(:entry, headword: "爱")
      senses = create_pair(:sense, entry:)

      expect(occurrence.senses).to eq(senses)
    end

    it "leaves out the same headword in another language" do
      create(:sense, entry: create(:entry, headword: "爱", language: "ja"))

      expect(occurrence.senses).to eq([])
    end

    it "sees a sense created since it was last asked" do
      waiting = occurrence
      waiting.senses
      sense = create(:sense, entry: create(:entry, headword: "爱"))

      expect(waiting.senses).to eq([sense])
    end
  end

  describe "#to_prompt" do
    it "points at its sentence and word under the id" do
      expect(occurrence.to_prompt(3, sid: 1, wid: 2))
        .to include(id: 3, sid: 1, wid: 2)
    end

    it "names the word as well as pointing at it" do
      expect(occurrence.to_prompt(0, sid: 0, wid: 0)).to include(word: "爱")
    end

    it "marks the token among its neighbours" do
      expect(occurrence.to_prompt(0, sid: 0, wid: 0))
        .to include(marked: "我【爱】你")
    end

    it "marks only the token at the index when the word repeats" do
      repeated = occurrence(words: ["花", "钱", "买", "花"], index: 3)

      expect(repeated.to_prompt(0, sid: 0, wid: 0)).to include(marked: "花钱买【花】")
    end

    it "shows a window of the sentence rather than all of it" do
      words = ["一", "二", "三", "四", "五", "六", "七", "八", "九"]

      expect(occurrence(words:, index: 4).to_prompt(0, sid: 0, wid: 0))
        .to include(marked: "二三四【五】六七八")
    end
  end

  describe "#word_prompt" do
    it "gives the word under the id" do
      expect(occurrence.word_prompt(4)).to include(wid: 4, word: "爱")
    end

    it "gives the headword" do
      expect(occurrence.word_prompt(0)).to include(headword: "爱")
    end

    it "lists each sense with its headword and reading" do
      entry = create(:entry, headword: "爱", reading: "ài")
      sense = create(:sense, entry:, gloss: "to love")
      listed = { id: sense.id, headword: "爱", reading: "ài", gloss: "to love" }

      expect(occurrence.word_prompt(0)[:senses]).to eq([listed])
    end
  end
end
