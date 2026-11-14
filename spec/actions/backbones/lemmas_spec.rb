# frozen_string_literal: true

RSpec.describe Backbones::Lemmas do
  after { FileUtils.rm_rf(cache_dir) }

  def cache_dir = Rails.root.join("tmp/spec/lemmas-#{Process.pid}")

  def lemmas = described_class.new(cache_dir.join("cache/lemmas.json"))

  def row(id, kind: "word", lemmas: ["casa"], alternatives: [])
    { id:, kind:, lemmas:, alternatives: }
  end

  def word(form, kind: "word", lemmas: ["casa"], alternatives: [])
    Backbones::Lemmas::Word.new(form:, kind:, lemmas:, alternatives:)
  end

  describe "#for" do
    it "asks nothing for no occurrences" do
      lemmas.for([])

      expect(llm.calls).to be_empty
    end

    it "asks Sonnet" do
      llm.answer({ words: [row(0)] })

      lemmas.for([["casas", "As casas."]])

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "asks about each form once, with its first sentence" do
      llm.answer({ words: [row(0)] })
      prompt = [{ id: 0, form: "casas", sentence: "As casas." }]

      lemmas.for([["casas", "As casas."], ["casas", "Mais casas."]])

      expect(llm.calls.sole.prompt).to eq(prompt.to_json)
    end

    it "asks in batches" do
      stub_const("Backbones::Lemmas::BATCH", 1)
      llm.answer({ words: [row(0)] }, { words: [row(0)] })

      lemmas.for([["casas", "As casas."], ["casa", "A casa."]])

      expect(llm.calls.size).to eq(2)
    end

    it "gives a word for each occurrence" do
      llm.answer({ words: [row(0)] })

      words = lemmas.for([["casas", "As casas."], ["casas", "Mais casas."]])

      expect(words).to eq([word("casas"), word("casas")])
    end

    it "gives the answer's kind, lemmas and alternatives" do
      given = { kind: "name", lemmas: ["ana"], alternatives: ["anna"] }
      llm.answer({ words: [row(0, **given)] })

      expect(lemmas.for([["Ana", "Ana."]])).to eq([word("Ana", **given)])
    end

    it "lower-cases the lemmas and alternatives" do
      llm.answer({ words: [row(0, lemmas: ["Casa"], alternatives: ["Lar"])] })

      words = lemmas.for([["casas", "As casas."]])

      expect(words.sole).to eq(word("casas", alternatives: ["lar"]))
    end

    it "gives an unknown word for a form the answer leaves out" do
      llm.answer({ words: [] })

      words = lemmas.for([["casas", "As casas."]])

      expect(words).to eq([word("casas", kind: "unknown", lemmas: [])])
    end

    it "remembers its answers for next time" do
      llm.answer({ words: [row(0)] })
      lemmas.for([["casas", "As casas."]])

      expect(lemmas.for([["casas", "Mais casas."]])).to eq([word("casas")])
    end

    it "asks again about a form left out before" do
      llm.answer({ words: [] }, { words: [row(0)] })
      lemmas.for([["casas", "As casas."]])

      expect(lemmas.for([["casas", "As casas."]])).to eq([word("casas")])
    end
  end
end
