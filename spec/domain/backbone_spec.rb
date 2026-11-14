# frozen_string_literal: true

RSpec.describe Backbone do
  def tale = described_class.find("tale", root: file_fixture("backbones"))

  def bare
    levels = [{ "code" => "A1", "list" => "L", "strict" => true }]
    config = { "language" => "pt", "levels" => levels }

    described_class.new("bare", config, dir: nil)
  end

  def b1 = tale.level("B1")
  def a1 = tale.level("A1")

  describe ".find" do
    it "reads the backbone's title and author" do
      expect([tale.title, tale.author]).to eq(["O Conto", "Ana Autora"])
    end

    it "reads its language" do
      expect(tale.language).to eq("pt")
    end

    it "reads its levels top-down" do
      expect(tale.levels.map(&:code)).to eq(["B1", "A1"])
    end

    it "reads each level's list, strictness and guidelines" do
      level = { code: "B1", list: "Tale B1", strict: true }

      expect(b1).to eq(Backbone::Level.new(**level, guidelines: "Past tenses."))
    end

    it "reads its title words" do
      expect(tale.title_words).to eq(["dr"])
    end

    it "reads its notes" do
      expect(tale.notes).to eq("Keep the narrator's jokes.")
    end
  end

  describe ".new" do
    it "has no title words unless the config gives some" do
      expect(bare.title_words).to eq([])
    end

    it "has no story words unless the config gives some" do
      expect(bare.story_words(bare.levels.first)).to eq([])
    end

    it "has no notes unless the config gives some" do
      expect(bare.notes).to eq("")
    end

    it "gives a level no guidelines unless the config gives some" do
      expect(bare.levels.first.guidelines).to eq("")
    end
  end

  describe "#prompt_terms" do
    it "names the work, its author and its language" do
      terms = { work: "O Conto", author: "Ana Autora", language: "Portuguese" }

      expect(tale.prompt_terms).to eq(terms)
    end
  end

  describe "#cache_dir" do
    it "is the backbone's folder under the cache" do
      expect(tale.cache_dir).to eq(Rails.root.join("tmp/backbones/tale"))
    end
  end

  describe "#level" do
    it "finds a level by its code" do
      expect(a1.list).to eq("Tale A1")
    end

    it "raises for a level the backbone doesn't have" do
      expect { tale.level("C2") }.to raise_error(ArgumentError, "No level C2")
    end
  end

  describe "#above" do
    it "gives the level a level is written from" do
      expect(tale.above(a1)).to eq(b1)
    end

    it "gives nothing for the top level" do
      expect(tale.above(b1)).to be_nil
    end
  end

  describe "#up_to" do
    it "gives the level and those below it" do
      expect(tale.up_to(b1).map(&:code)).to eq(["B1", "A1"])
    end

    it "gives only the first level for the first" do
      expect(tale.up_to(a1).map(&:code)).to eq(["A1"])
    end
  end

  describe "#story_words" do
    it "gives the recurring words at every level" do
      expect(tale.story_words(b1)).to eq(["hospício"])
    end

    it "adds the words of that level alone" do
      expect(tale.story_words(a1)).to eq(["hospício", "louco"])
    end
  end

  describe "#chapters" do
    it "names the chapters in the order of the headings" do
      expect(tale.chapters).to eq(["I", "II"])
    end
  end

  describe "paths" do
    def path(name) = file_fixture("backbones").join("tale", name)

    it "gives a chapter's text in its level's folder" do
      expect(tale.text_path(a1, "II")).to eq(path("A1/II.txt"))
    end

    it "gives a chapter's original" do
      expect(tale.original_path("II")).to eq(path("original/II.txt"))
    end

    it "writes a level from the level above" do
      expect(tale.source_path(a1, "II")).to eq(path("B1/II.txt"))
    end

    it "writes the top level from the original" do
      expect(tale.source_path(b1, "II")).to eq(path("original/II.txt"))
    end

    it "gives where a stopped draft waits" do
      expect(tale.draft_path(a1, "II")).to eq(path("A1/II.draft.txt"))
    end

    it "gives where why it stopped is kept" do
      expect(tale.trouble_path(a1, "II")).to eq(path("A1/II.trouble.md"))
    end
  end

  describe "#heading" do
    it "gives a version's heading for a chapter" do
      heading = { "title" => "Um", "translation" => "One" }

      expect(tale.heading("original", "I")).to eq(heading)
    end

    it "gives nothing for a heading not yet written" do
      expect(tale.heading("A1", "I")).to be_nil
    end
  end

  describe "#heading_title" do
    it "gives a version's title for a chapter" do
      expect(tale.heading_title("original", "II")).to eq("Dois")
    end

    it "gives nothing for a heading not yet written" do
      expect(tale.heading_title("A1", "II")).to be_nil
    end
  end

  describe "#save_heading" do
    def saved
      backbone = tale_backbone
      backbone.save_heading(b1, "II", title: "Dois", translation: "Two")
      backbone
    end

    it "keeps a level's heading for a chapter" do
      heading = { "title" => "Dois", "translation" => "Two" }

      expect(saved.heading("B1", "II")).to eq(heading)
    end

    it "keeps the chapter's other headings" do
      expect(saved.heading("original", "II")).to include("title" => "Dois")
    end

    it "starts a chapter the headings don't have yet" do
      backbone = tale_backbone
      backbone.save_heading(b1, "III", title: "Três", translation: "Three")

      expect(backbone.chapters).to eq(["I", "II", "III"])
    end
  end
end
