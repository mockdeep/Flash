# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Refine do
  def suggestion(headword)
    {
      headword:,
      problem: "gloss",
      reason: "too broad",
      examples: [],
      confidence: "high",
      edits: [{ action: "revise", sense: "1", gloss: "flower" }],
    }
  end

  # Flags the headwords given, Opus keeps everything, and every source's
  # cast is Louis alone.
  def answer(*headwords)
    llm.respond do |call|
      case call.system
      when Compendium::Cast::SYSTEM then { narrator: "Louis", characters: [] }
      when /\AYou review/ then { suggestions: headwords.map { suggestion(it) } }
      else { verdicts: headwords.each_index.map { { id: it, keep: true } } }
      end
    end
  end

  def summary(rest) = "Reviewed 1 zh entries (花 … 花): #{rest}"

  def files_written = Dir.mktmpdir { |dir| refine(dir) && written(dir) }

  def used_in_one_snippet(*headwords)
    snippet = create(:snippet, :finished)
    headwords.each do |headword|
      used_in_snippet(create(:entry, headword:), snippet:)
    end
  end

  def kept(headword)
    suggestion(headword).except(:headword).merge(confirmed: nil).as_json
  end

  def refine(dir, **, &) = described_class.call(dir: Pathname(dir), **, &)

  def written(dir)
    Dir.children(dir).map { JSON.parse(File.read("#{dir}/#{it}")) }
  end

  def used_in_snippet(entry, snippet: create(:snippet, :finished), **token)
    sense = create(:sense, entry:)
    tokens = [{ "text" => "花", "sense_id" => sense.id, **token }]
    create(:snippet_sentence, snippet:, body: "花", tokens:)
  end

  describe ".call" do
    it "marks every entry it reviews" do
      answer
      entry = create(:entry)

      Dir.mktmpdir { refine(it) }

      expect(entry.reload.reviewed_at).to be_present
    end

    it "returns how many entries it reviewed" do
      answer
      create_list(:entry, 2)

      expect(Dir.mktmpdir { refine(it) }).to eq(2)
    end

    it "reviews each entry once a run" do
      answer
      create(:entry)

      Dir.mktmpdir { refine(it) }

      expect(llm.calls.size).to eq(1)
    end

    it "stops once it has reviewed the limit" do
      answer
      stub_const("#{described_class}::BATCH", 1)
      create_list(:entry, 3)

      expect(Dir.mktmpdir { refine(it, limit: 2) }).to eq(2)
    end

    it "brings in every entry sharing a batch's headwords" do
      answer
      stub_const("#{described_class}::BATCH", 1)
      create(:entry, headword: "过", reading: "guò")
      create(:entry, headword: "过", reading: "guo")

      expect(Dir.mktmpdir { refine(it, limit: 1) }).to eq(2)
    end

    it "keeps a batch to one language" do
      answer
      create(:entry, language: "zh")
      create(:entry, language: "pt")

      Dir.mktmpdir { refine(it) }

      expect(llm.calls.map(&:system).uniq.size).to eq(2)
    end

    it "writes a headword's kept suggestions to a file" do
      answer("花")
      create(:entry, headword: "花")

      expect(files_written.sole).to include("suggestions" => [kept("花")])
    end

    it "gives the file the headword's entries" do
      answer("花")
      entry = create(:entry, headword: "花")

      expect(files_written.sole).to include("entry_ids" => [entry.id])
    end

    it "names the file for the headword's language and first entry" do
      answer("花")
      entry = create(:entry, headword: "花")

      names = Dir.mktmpdir { |dir| refine(dir) && Dir.children(dir) }

      expect(names).to eq(["zh-#{entry.id}.json"])
    end

    it "writes nothing for a headword not in the batch" do
      answer("树")
      create(:entry, headword: "花")

      expect(Dir.mktmpdir { |dir| refine(dir) && Dir.children(dir) })
        .to be_empty
    end

    it "reports each batch" do
      answer("花")
      create(:entry, headword: "花")

      expect { |block| Dir.mktmpdir { refine(it, &block) } }
        .to yield_with_args(summary("kept 1 of 1 suggestions"))
    end

    it "reports suggestions for a headword not in the batch" do
      answer("树")
      create(:entry, headword: "花")

      expect { |block| Dir.mktmpdir { refine(it, &block) } }
        .to yield_with_args(/dropped those for 树, not in the batch/)
    end

    it "gives the cast note of each source its sentences come from" do
      answer
      used_in_snippet(create(:entry))

      Dir.mktmpdir { refine(it) }

      expect(JSON.parse(llm.calls.last.prompt)["casts"].sole)
        .to include("narrator" => "Louis")
    end

    it "gives no cast note for a source with no finished snippet" do
      answer
      used_in_snippet(create(:entry), snippet: create(:snippet), outcome: "ok")

      Dir.mktmpdir { refine(it) }

      expect(JSON.parse(llm.calls.last.prompt)["casts"]).to be_empty
    end

    it "builds a source's cast note once a run" do
      answer
      stub_const("#{described_class}::BATCH", 1)
      used_in_one_snippet("花", "树")

      Dir.mktmpdir { refine(it) }

      expect(llm.calls.count { it.system == Compendium::Cast::SYSTEM }).to eq(1)
    end

    it "leaves a batch unmarked when Claude fails" do
      llm.fail("usage limit reached")
      entry = create(:entry)

      Dir.mktmpdir { |dir| suppress(Llm::Error) { refine(dir) } }

      expect(entry.reload.reviewed_at).to be_nil
    end
  end
end
