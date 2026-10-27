# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::SplitSentences do
  def split(body) = described_class.call(body, Language::MANDARIN)

  def split_portuguese(body)
    described_class.call(body, Language::PORTUGUESE)
  end

  def split_filipino(body) = described_class.call(body, Language::FILIPINO)

  describe ".call" do
    it "splits on terminal punctuation" do
      expect(split("我爱你。你呢？好！")).to eq(["我爱你。", "你呢？", "好！"])
    end

    it "keeps a closing quote with the sentence it ends" do
      expect(split("他说：“好。”我走了。")).to eq(["他说：“好。”", "我走了。"])
    end

    it "splits on line breaks" do
      expect(split("孔乙己\n鲁迅")).to eq(["孔乙己", "鲁迅"])
    end

    it "drops blank lines and surrounding space" do
      expect(split("  我爱你。 \n\n  \n")).to eq(["我爱你。"])
    end
  end

  describe ".call in Portuguese" do
    it "splits on terminal punctuation" do
      expect(split_portuguese("Ela chegou cedo. Ninguém estava em casa!"))
        .to eq(["Ela chegou cedo.", "Ninguém estava em casa!"])
    end

    it "keeps a closing quote with the sentence it ends" do
      expect(split_portuguese("Ele disse: “Vamos.” E saiu."))
        .to eq(["Ele disse: “Vamos.”", "E saiu."])
    end

    it "does not split after a title" do
      expect(split_portuguese("O Sr. Almeida saiu."))
        .to eq(["O Sr. Almeida saiu."])
    end

    it "does not split after a saint's title" do
      expect(split_portuguese("No cemitério de St. Louis, em Nova Orleans."))
        .to eq(["No cemitério de St. Louis, em Nova Orleans."])
    end

    it "does not split after a word that only starts like a title" do
      expect(split_portuguese("Saiu cedo. Stella ficou."))
        .to eq(["Saiu cedo.", "Stella ficou."])
    end

    it "does not split after an initial" do
      expect(split_portuguese("Leu J. R. Ward ontem."))
        .to eq(["Leu J. R. Ward ontem."])
    end

    it "keeps a line of dialogue with its speech tag" do
      expect(split_portuguese("— Quem é? — perguntou ela. — Sou eu."))
        .to eq(["— Quem é? — perguntou ela.", "— Sou eu."])
    end

    it "runs on past an ellipsis before a lower-case word" do
      expect(split_portuguese("Eu... não sei. Talvez amanhã."))
        .to eq(["Eu... não sei.", "Talvez amanhã."])
    end
  end

  describe ".call in Filipino" do
    it "splits on terminal punctuation" do
      expect(split_filipino("Hindi niya alam. Tama ka!"))
        .to eq(["Hindi niya alam.", "Tama ka!"])
    end

    it "does not split after a Filipino title" do
      expect(split_filipino("Dumating si Gng. Reyes kahapon."))
        .to eq(["Dumating si Gng. Reyes kahapon."])
    end

    it "keeps a line of dialogue with its speech tag" do
      expect(split_filipino("“Maliliit na susô!” sagot ni Padre Camora."))
        .to eq(["“Maliliit na susô!” sagot ni Padre Camora."])
    end
  end
end
