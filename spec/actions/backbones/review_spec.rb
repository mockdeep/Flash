# frozen_string_literal: true

RSpec.describe Backbones::Review do
  def problem
    { quote: "A", category: "story", why: "Unclear", replacement: "O" }
  end

  def text
    Backbones::Draft::Text.new(title: "Casa", translation: "House", text: "A.")
  end

  def review(verdict: "REWORK")
    backbone = tale_backbone
    llm.answer({ verdict:, problems: [problem] })

    described_class.call(backbone, backbone.level("A1"), "I", text)
  end

  def prompt = JSON.parse(llm.calls.sole.prompt)

  describe ".call" do
    it "asks Opus" do
      review

      expect(llm.calls.sole.model).to eq("claude-opus-5-5")
    end

    it "names the work, its author and its language" do
      review

      expect(llm.calls.sole.system).to include("Ana Autora for learners of")
    end

    it "gives what the writer was given" do
      review

      expect(prompt["above"]).to include("version" => "B1")
    end

    it "gives the original" do
      review
      text = file_fixture("backbones/tale/original/I.txt").read

      expect(prompt["original"]).to eq("title" => "Um", "text" => text)
    end

    it "gives the draft" do
      review

      expect(prompt["draft"]).to eq(text.to_h.stringify_keys)
    end

    it "gives a PASS as passing" do
      expect(review(verdict: "PASS")).to be_pass
    end

    it "gives a REWORK as not passing" do
      expect(review).not_to be_pass
    end

    it "gives the problems" do
      expect(review.problems).to eq([Backbones::Review::Problem.new(**problem)])
    end
  end
end
