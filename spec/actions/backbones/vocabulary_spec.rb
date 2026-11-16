# frozen_string_literal: true

RSpec.describe Backbones::Vocabulary do
  def write(backbone, chapter, text)
    path = backbone.original_path(chapter)
    text ? path.write(text) : path.delete
  end

  def vocabulary(*, second: "A rua velha. O cão.")
    backbone = tale_backbone
    write(backbone, "I", "Rua, ruas, rua. Uma casa. O cão.")
    write(backbone, "II", second)
    tale_list("A1", "a", "o", "casa")
    tale_list("B1", "rua")
    llm.respond { lemma_answer(it, ruas: { lemmas: ["rua"] }) }

    described_class.call("tale", "A1", *)
  end

  def bases(lines) = lines.drop(1).map { it.split[2] }

  describe ".call" do
    it "says how many base forms are above the level" do
      heading = "2 base forms the original uses 2+ times above A1:"

      expect(vocabulary("2").first).to eq(heading)
    end

    it "lists the words above the level in every chapter, most used first" do
      expect(bases(vocabulary("2"))).to eq(["rua", "cão"])
    end

    it "gives each word's count, the level that lists it and its forms" do
      line = "     4  B1   #{"rua".ljust(20)} rua, Rua, ruas"

      expect(vocabulary("2").second).to eq(line)
    end

    it "marks a word no list holds" do
      expect(vocabulary("2").third).to start_with("     2  -    cão")
    end

    it "leaves out words used fewer times than the minimum" do
      expect(bases(vocabulary("3"))).to eq(["rua"])
    end

    it "leaves out words used fewer than five times by default" do
      expect(bases(vocabulary)).to eq([])
    end

    it "skips a chapter without an original" do
      expect(vocabulary("1", second: nil).second).to start_with("     3  B1")
    end
  end
end
