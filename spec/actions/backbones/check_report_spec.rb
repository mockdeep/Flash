# frozen_string_literal: true

RSpec.describe Backbones::CheckReport do
  def answers(**given)
    llm.respond { lemma_answer(it, **given) }
  end

  def report(*)
    tale_backbone
    tale_list("A1", "a", "casa")
    tale_list("B1", "rua")

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
