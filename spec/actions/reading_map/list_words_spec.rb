# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingMap::ListWords do
  # A Portuguese source's list holding the words its one sentence writes.
  def list_writing(*texts, category: nil)
    word_list = create(:word_list, language: "pt")
    snippet = create(:snippet, word_list:)
    tokens = texts.map { token(word_list, it, category) }
    create(:snippet_sentence, snippet:, body: texts.join(" "), tokens:)
    word_list
  end

  def token(word_list, text, category)
    entry = create(:entry, language: "pt", headword: text)
    sense = create(:sense, entry:)
    create(:sense_membership, sense:, word_list:, category:)
    { "text" => text, "sense_id" => sense.id }
  end

  def words(word_list, known: [], **given)
    llm.respond { lemma_answer(it, **given) }

    described_class.call(word_list, known: known.to_set)
  end

  describe ".call" do
    it "gives each word under its headword, in lower case" do
      list = create(:word_list)
      entry = create(:entry, headword: "Ming")
      create(:sense_membership, word_list: list, sense: create(:sense, entry:))

      expect(words(list)).to eq([[["ming"]]])
    end

    it "gives an entry with several senses once" do
      list = create(:word_list)
      entry = create(:entry, headword: "花")
      senses = create_list(:sense, 2, entry:)
      senses.each { create(:sense_membership, word_list: list, sense: it) }

      expect(words(list)).to eq([[["花"]]])
    end

    it "leaves out a word filed as a name" do
      list = list_writing("Itaguaí", category: "proper noun")

      expect(words(list)).to be_empty
    end

    it "adds a word's base form" do
      list = list_writing("falávamos")
      given = { falávamos: { lemmas: ["falar"] } }

      expect(words(list, **given)).to eq([[["falávamos"], ["falar"]]])
    end

    it "keeps a contraction's parts together" do
      list = list_writing("do")
      given = { do: { lemmas: ["de", "o"] } }

      expect(words(list, **given)).to eq([[["do"], ["de", "o"]]])
    end

    it "adds another headword for the word" do
      list = list_writing("juntos")
      given = { juntos: { lemmas: ["junto"], alternatives: ["juntos"] } }

      expect(words(list, **given)).to eq([[["juntos"], ["junto"], ["juntos"]]])
    end

    it "leaves out a word the answer calls a name" do
      list = list_writing("Itaguaí")

      expect(words(list, Itaguaí: { kind: "name" })).to be_empty
    end

    it "keeps a word the answer leaves out under its headword" do
      list = list_writing("casa")
      llm.respond { { words: [] } }

      expect(described_class.call(list, known: Set.new)).to eq([[["casa"]]])
    end

    it "asks for the word as its sentence writes it" do
      words(list_writing("Casa", "velha"))

      expect(JSON.parse(llm.calls.sole.prompt).first)
        .to eq("id" => 0, "form" => "Casa", "sentence" => "Casa velha")
    end

    it "asks nothing about a word the level lists hold as written" do
      words(list_writing("casa"), known: ["casa"])

      expect(llm.calls).to be_empty
    end

    it "asks nothing in a language with no base forms" do
      list = create(:word_list)
      create(:sense_membership, word_list: list)
      words(list)

      expect(llm.calls).to be_empty
    end

    it "asks nothing about a word no sentence writes" do
      list = create(:word_list, language: "pt")
      create(:sense_membership, word_list: list)
      words(list)

      expect(llm.calls).to be_empty
    end
  end
end
