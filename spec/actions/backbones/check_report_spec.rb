# frozen_string_literal: true

RSpec.describe Backbones::CheckReport do
  after { FileUtils.rm_rf(cache_dir) }

  def cache_dir = Rails.root.join("tmp/spec/check-report-#{Process.pid}")

  def list(code, *headwords)
    word_list = create(:word_list, name: "Tale #{code}", language: "pt")
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

  def report(*)
    stub_const("Backbone::ROOT", file_fixture("backbones"))
    stub_const("Backbones::CheckReport::CACHE", cache_dir)
    list("A1", "a", "casa")
    list("B1", "rua")

    described_class.call("tale", *)
  end

  describe ".call" do
    it "reports every text written, level by level" do
      answers
      headers = ["B1 I", "A1 I", "A1 II"]

      expect(report.grep(/words/).map { it.split(":").first }).to eq(headers)
    end

    it "reports one level" do
      answers

      expect(report("B1")).to eq(["B1 I: 4 words, clean"])
    end

    it "reports one chapter of every level" do
      answers

      expect(report("", "II").first).to start_with("A1 II:")
    end

    it "reports one chapter of one level" do
      answers

      headers = ["A1 I: 3 words, above level"]

      expect(report("A1", "I").grep(/words/)).to eq(headers)
    end

    it "lists each word above the level with its level and forms" do
      answers(rua: { lemmas: ["rua"] })

      expect(report("A1", "II").last).to eq("  B1   #{"rua".ljust(22)} rua×2")
    end

    it "gives a form written once without a count" do
      answers

      expect(report("A1", "I").last).to end_with(" velha")
    end

    it "marks a text with words above its level" do
      answers

      expect(report("A1", "II").first).to eq("A1 II: 4 words, above level")
    end

    it "marks a word no list holds" do
      answers(rua: { lemmas: ["beco"] })

      expect(report("A1", "II").last).to start_with("  -    beco")
    end

    it "names the forms no answer covered" do
      llm.respond { { words: [] } }

      expect(report("A1", "I").last).to eq("  no answer for: A, casa, velha")
    end
  end
end
