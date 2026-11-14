# frozen_string_literal: true

RSpec.describe Backbone do
  def tale = described_class.find("tale", root: file_fixture("backbones"))

  def bare
    levels = [{ "code" => "A1", "list" => "L", "strict" => true, "share" => 1 }]
    config = { "language" => "pt", "levels" => levels }

    described_class.new("bare", config, dir: nil)
  end

  describe ".find" do
    it "reads the backbone's language" do
      expect(tale.language).to eq("pt")
    end

    it "reads its levels top-down" do
      expect(tale.levels.map(&:code)).to eq(["B1", "A1"])
    end

    it "reads each level's list, strictness and share" do
      level = { code: "B1", list: "Tale B1", strict: true, share: 0.3 }

      expect(tale.levels.first).to eq(Backbone::Level.new(**level))
    end

    it "reads its title words" do
      expect(tale.title_words).to eq(["dr"])
    end
  end

  describe ".new" do
    it "has no title words unless the config gives some" do
      expect(bare.title_words).to eq([])
    end

    it "has no story words unless the config gives some" do
      expect(bare.story_words(bare.levels.first)).to eq([])
    end
  end

  describe "#level" do
    it "finds a level by its code" do
      expect(tale.level("A1").list).to eq("Tale A1")
    end

    it "raises for a level the backbone doesn't have" do
      expect { tale.level("C2") }.to raise_error(ArgumentError, "No level C2")
    end
  end

  describe "#up_to" do
    it "gives the level and those below it" do
      expect(tale.up_to(tale.level("B1")).map(&:code)).to eq(["B1", "A1"])
    end

    it "gives only the first level for the first" do
      expect(tale.up_to(tale.level("A1")).map(&:code)).to eq(["A1"])
    end
  end

  describe "#story_words" do
    it "gives the recurring words at every level" do
      expect(tale.story_words(tale.level("B1"))).to eq(["hospício"])
    end

    it "adds the words of that level alone" do
      expect(tale.story_words(tale.level("A1"))).to eq(["hospício", "louco"])
    end
  end

  describe "#chapters" do
    it "names the chapters in the order of the headings" do
      expect(tale.chapters).to eq(["I", "II"])
    end
  end

  describe "#text_path" do
    it "gives a chapter's file in its level's folder" do
      path = file_fixture("backbones").join("tale/A1/II.txt")

      expect(tale.text_path(tale.level("A1"), "II")).to eq(path)
    end
  end
end
