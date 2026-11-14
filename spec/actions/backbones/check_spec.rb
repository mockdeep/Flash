# frozen_string_literal: true

RSpec.describe Backbones::Check do
  after { FileUtils.rm_rf(cache_dir) }

  def cache_dir = Rails.root.join("tmp/spec/check-#{Process.pid}")

  def level(code, strict)
    list = "Tale #{code}"

    { "code" => code, "list" => list, "strict" => strict, "share" => 1 }
  end

  def backbone
    config = {
      "language" => "pt",
      "levels" => [level("B1", false), level("A1", true)],
      "recurring_words" => ["hospício"],
      "level_words" => { "A1" => ["louco"] },
      "title_words" => ["dr"],
    }

    Backbone.new("tale", config, dir: nil)
  end

  def list(code, *headwords)
    word_list = WordList.find_by(name: "Tale #{code}") ||
      create(:word_list, name: "Tale #{code}", language: "pt")
    headwords.each do |headword|
      entry = create(:entry, language: "pt", headword:)
      create(:sense_membership, word_list:, sense: create(:sense, entry:))
    end
  end

  # Each form's answer is its own lower-case form, unless given here.
  def answers(**given)
    llm.respond do |call|
      words =
        JSON.parse(call.prompt).map do |item|
          form = item["form"]
          default = { kind: "word", lemmas: [form.downcase], alternatives: [] }
          default.merge(id: item["id"], **given.fetch(form.to_sym, {}))
        end
      { words: }
    end
  end

  def check(text, level: "A1", **given)
    answers(**given)

    check_only(text, level)
  end

  def check_unanswered(text)
    llm.respond { { words: [] } }

    check_only(text, "A1")
  end

  def check_only(text, code)
    list("A1", "a", "casa")
    list("B1", "rua")
    lemmas = Backbones::Lemmas.new(cache_dir.join("lemmas.json"))

    described_class.call(backbone, backbone.level(code), text, lemmas:)
  end

  def flagged(...) = check(...).flags.map(&:base)

  describe ".call" do
    it "counts the text's words" do
      expect(check("A casa. A rua.").words).to eq(4)
    end

    it "leaves names out of the count" do
      expect(check("A Ana.", Ana: { kind: "name" }).words).to eq(1)
    end

    it "asks about each word with its sentence" do
      check("A casa. A rua.")

      expect(llm.calls.sole.prompt).to include('"sentence":"A rua."')
    end

    it "passes words listed at the level" do
      expect(flagged("A casa.")).to eq([])
    end

    it "passes words listed below the level" do
      expect(flagged("A casa.", level: "B1")).to eq([])
    end

    it "flags words listed above the level" do
      expect(flagged("A rua.")).to eq(["rua"])
    end

    it "gives the level a flagged word is listed at" do
      expect(check("A rua.").flags.sole.listed).to eq("B1")
    end

    it "flags words no list holds" do
      expect(check("O cão.").flags.map(&:listed)).to eq([nil, nil])
    end

    it "counts the forms a flagged word is written in" do
      result = check("Ruas. A rua. Ruas.", Ruas: { lemmas: ["rua"] })

      expect(result.flags.sole.forms).to eq("Ruas" => 2, "rua" => 1)
    end

    it "passes a form a list holds as written" do
      expect(flagged("Casa.", Casa: { lemmas: ["casar"] })).to eq([])
    end

    it "passes a word under another headword a list holds" do
      given = { Casinha: { alternatives: ["casa"] } }

      expect(flagged("Casinha.", **given)).to eq([])
    end

    it "flags only the parts of a word above the level" do
      expect(flagged("Narua.", Narua: { lemmas: ["a", "rua"] })).to eq(["rua"])
    end

    it "passes names" do
      expect(flagged("Ana.", Ana: { kind: "name" })).to eq([])
    end

    it "passes numerals" do
      expect(flagged("XII.", XII: { kind: "numeral" })).to eq([])
    end

    it "passes recurring story words" do
      expect(flagged("O hospício.", level: "B1")).to eq(["o"])
    end

    it "passes a level's own story words at that level" do
      expect(flagged("A louco.")).to eq([])
    end

    it "flags a level's own story words at other levels" do
      expect(flagged("A louco.", level: "B1")).to eq(["louco"])
    end

    it "passes a title before a name" do
      expect(flagged("A Dr Ana.", Ana: { kind: "name" })).to eq([])
    end

    it "flags a title before anything else" do
      expect(flagged("A casa dr.")).to eq(["dr"])
    end

    it "passes a reflexive verb's bare verb" do
      list("A1", "se chamar")

      expect(flagged("A chamar.")).to eq([])
    end

    it "orders flags by the level they're listed at, unlisted last" do
      expect(flagged("O cão rua.")).to eq(["rua", "cão", "o"])
    end

    it "gives the forms no answer covered" do
      expect(check_unanswered("A casa.").unknown).to eq(["A", "casa"])
    end
  end

  describe "Result#clean?" do
    it "is clean at a strict level with nothing above it" do
      expect(check("A casa.")).to be_clean
    end

    it "is not clean at a strict level with words above it" do
      expect(check("A rua.")).not_to be_clean
    end

    it "is not clean at a strict level with forms unanswered" do
      expect(check_unanswered("A casa.")).not_to be_clean
    end

    it "is clean at a level that only reports" do
      expect(check("O cão.", level: "B1")).to be_clean
    end
  end
end
