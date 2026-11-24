# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::CurriculumPhrases do
  # Finds the phrases with Portuguese's base forms, each form its own
  # unless given another.
  def found_in(*texts, phrases:, **given)
    llm.respond { lemma_answer(it, **given) }

    described_class.new(phrases, Lemmas.in("pt")).found_in_each(texts)
  end

  def listed(headword, language:, curriculum: true)
    list = create(:word_list, curriculum:, language:)
    sense = create(:sense, entry: create(:entry, headword:, language:))
    create(:sense_membership, sense:, word_list: list)
  end

  describe ".for" do
    it "finds a phrase of the language's curriculum lists" do
      listed("em cima", language: "pt")
      llm.respond { lemma_answer(it) }
      phrases = described_class.for(Language::PORTUGUESE)

      expect(phrases.found_in_each(["Está em cima."])).to eq([["em cima"]])
    end

    it "leaves out a phrase only other lists hold" do
      listed("em cima", language: "pt", curriculum: false)
      phrases = described_class.for(Language::PORTUGUESE)

      expect(phrases.found_in_each(["Está em cima."])).to eq([[]])
    end

    it "finds a phrase as written in a language with no base forms" do
      stub_const("Lemmas::LANGUAGES", ["pt"])
      listed("para sa", language: "fil")
      phrases = described_class.for(Language::FILIPINO)

      expect(phrases.found_in_each(["Ito ay para sa iyo."]))
        .to eq([["para sa"]])
    end

    it "asks for no base forms in a language that has none" do
      stub_const("Lemmas::LANGUAGES", ["pt"])
      listed("para sa", language: "fil")
      described_class.for(Language::FILIPINO).found_in_each(["Para sa iyo."])

      expect(llm.calls).to be_empty
    end
  end

  describe "#found_in_each" do
    it "finds a phrase written as listed" do
      found = found_in("Está em cima.", phrases: ["em cima"])

      expect(found).to eq([["em cima"]])
    end

    it "gives the phrase as the text writes it" do
      found = found_in("Em  cima!", phrases: ["em cima"])

      expect(found).to eq([["Em  cima"]])
    end

    it "finds a phrase with a word in another form" do
      given = { phrases: ["levar em conta"], levou: { lemmas: ["levar"] } }
      found = found_in("Ela levou em conta.", **given)

      expect(found).to eq([["levou em conta"]])
    end

    it "leaves out a phrase a contraction would finish" do
      given = { da: { lemmas: ["de", "a"] } }
      found = found_in("ao redor da casa", phrases: ["ao redor de"], **given)

      expect(found).to eq([[]])
    end

    it "leaves out words with punctuation between them" do
      found = found_in("Em, cima.", phrases: ["em cima"])

      expect(found).to eq([[]])
    end

    it "leaves out a phrase the text only starts" do
      found = found_in("Está em", phrases: ["em cima"])

      expect(found).to eq([[]])
    end

    it "leaves out a phrase whose later word differs" do
      found = found_in("em casa", phrases: ["em cima"])

      expect(found).to eq([[]])
    end

    it "lists a phrase once however often the text writes it" do
      found = found_in("em cima, em cima", phrases: ["em cima"])

      expect(found).to eq([["em cima"]])
    end

    it "keeps each text's phrases apart" do
      found = found_in("em cima", "de novo", phrases: ["em cima", "de novo"])

      expect(found).to eq([["em cima"], ["de novo"]])
    end

    it "asks for the texts' base forms together" do
      found_in("em cima", "de novo", phrases: ["em cima"])

      expect(llm.calls.size).to eq(1)
    end

    it "never looks for a single word" do
      found = found_in("desde ontem", phrases: ["desde", "de"])

      expect(found).to eq([[]])
    end

    it "asks for no base forms with no phrases to find" do
      found_in("desde ontem", phrases: ["desde"])

      expect(llm.calls).to be_empty
    end
  end
end
