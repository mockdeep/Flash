# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Briefing do
  def sentence(words)
    tokens = words.map { |word| { "text" => word } }
    build(:snippet_sentence, body: "#{words.join}。", tokens:)
  end

  def occurrences_in(*sentences)
    sentences.flat_map do |one|
      one.tokens.each_index.map do |index|
        Snippets::Occurrence.new(sentence: one, index:)
      end
    end
  end

  def briefing(*, proposed: [])
    described_class.call(occurrences_in(*), proposed:)
  end

  describe ".call" do
    it "gives each sentence once" do
      expect(briefing(sentence(["花", "买", "花"]))[:sentences])
        .to eq([{ sid: 0, text: "花买花。" }])
    end

    it "gives each distinct word once" do
      expect(briefing(sentence(["花", "买", "花"]))[:words].pluck(:word))
        .to eq(["花", "买"])
    end

    it "lists a word once per headword it stands for" do
      tokens = [{ "text" => "著", "simplified" => "着" }, { "text" => "著" }]
      zhe = build(:snippet_sentence, body: "著著", tokens:)

      expect(briefing(zhe)[:words].pluck(:headword)).to eq(["着", "著"])
    end

    it "gives a prompt per occurrence" do
      expect(briefing(sentence(["花", "买", "花"]))[:occurrences].size).to eq(3)
    end

    it "points each occurrence at its word" do
      occurrences = briefing(sentence(["花", "买", "花"]))[:occurrences]

      expect(occurrences.pluck(:wid)).to eq([0, 1, 0])
    end

    it "points each occurrence at its sentence" do
      prompt = briefing(sentence(["我"]), sentence(["你", "好"]))

      expect(prompt[:occurrences].pluck(:sid)).to eq([0, 1, 1])
    end

    it "adds each occurrence's proposed sense" do
      proposed = [{ gloss: "to love" }]

      expect(briefing(sentence(["爱"]), proposed:)[:occurrences])
        .to contain_exactly(include(id: 0, gloss: "to love"))
    end
  end
end
