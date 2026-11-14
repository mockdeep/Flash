# frozen_string_literal: true

RSpec.describe Backbones::Run do
  # Every draft is the text given and every review a PASS.
  def answer(text)
    llm.respond do |call|
      if lemma_call?(call)
        lemma_answer(call)
      elsif review_call?(call)
        { verdict: "PASS", problems: [] }
      else
        { title: "Casa", translation: "House", text: }
      end
    end
  end

  # The fixture backbone, with chapter II's B1 and A1 texts not yet written.
  def tale(text: "A casa.")
    backbone = tale_backbone
    backbone.text_path(backbone.level("A1"), "II").delete
    tale_list("A1", "casa", "a")
    tale_list("B1", "rua")
    answer(text)
    backbone
  end

  def stuck = tale(text: "A velha rua.")
  def run(*) = described_class.call("tale", *)
  def text(backbone, chapter) = backbone.text_path(a1(backbone), chapter).read
  def a1(backbone) = backbone.level("A1")
  def b1(backbone) = backbone.level("B1")
  def stopped = "stopped, above the level after 3 rounds: velha"

  describe ".call" do
    it "writes the chapters' missing texts top-down" do
      tale

      expect(run).to start_with("II B1: written", "II A1: written")
    end

    it "leaves texts already written alone" do
      backbone = tale
      run

      expect(text(backbone, "I")).to eq("A casa velha.\n")
    end

    it "saves a written text" do
      backbone = tale
      run

      expect(text(backbone, "II")).to eq("A casa.\n")
    end

    it "saves a written text's heading" do
      backbone = tale
      run

      expect(backbone.heading("A1", "II")).to include("title" => "Casa")
    end

    it "lists the headings it wrote" do
      tale

      headings = ["  II B1: Casa (House)", "  II A1: Casa (House)"]

      expect(run.last(2)).to eq(headings)
    end

    it "lists no headings when it wrote none" do
      tale

      expect(run("I")).to eq([])
    end

    it "logs each text it wrote" do
      backbone = tale
      run
      log = backbone.cache_dir.join("logs/II-A1.log")

      expect(log.read).to start_with("Drafted")
    end

    it "writes one chapter" do
      tale

      expect(run("II", "")).to include("II A1: written")
    end

    it "writes one level" do
      tale

      expect(run("", "B1").first(2)).to eq(["II B1: written", ""])
    end

    it "waits on the level above" do
      tale

      expect(run("II", "A1")).to eq(["II A1: waiting on B1"])
    end

    it "waits on the original" do
      tale

      expect(run("III", "B1")).to eq(["III B1: waiting on original"])
    end

    it "says why a draft stopped" do
      stuck

      expect(run("II")).to eq(["II B1: #{stopped}"])
    end

    it "keeps a stopped draft beside its text" do
      backbone = stuck
      run("II")

      draft = backbone.draft_path(b1(backbone), "II")

      expect(draft.read).to eq("A velha rua.\n")
    end

    it "keeps why a draft stopped" do
      backbone = stuck
      run("II")
      note = backbone.trouble_path(b1(backbone), "II")

      expect(note.read).to start_with("# II B1: above the level after 3 rounds")
    end

    it "waits on a stopped draft" do
      stuck
      run("II")

      expect(run("II")).to eq(["II B1: waiting on its stopped draft"])
    end
  end
end
