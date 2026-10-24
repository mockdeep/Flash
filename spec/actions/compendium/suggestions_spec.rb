# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Suggestions do
  def file(path, *suggestions, entries: [], language: "zh")
    content = {
      language:,
      headword: "花",
      entry_ids: entries.map(&:id),
      reviewed_at: Time.current.iso8601(6),
      suggestions: suggestions.map { |edits| { problem: "gloss", edits: } },
    }
    File.write(path, content.to_json)
    path
  end

  def suggestion_file(*, **)
    file(File.join(Dir.mktmpdir, "zh-1.json"), *, **)
  end

  def apply(*edits, **) = described_class.apply(suggestion_file(edits, **), 0)

  def sense_edit(action, sense, **) = { action:, sense: sense.id.to_s, ** }

  def repointed(sentence, to)
    apply(
      {
        action: "repoint",
        sentence_id: sentence.id,
        token: 0,
        sense: to.id.to_s,
      },
    )
  end

  def added(**fields)
    { action: "add", headword: "发", reading: "fà", gloss: "hair", **fields }
  end

  def list_edit(action, membership, **)
    sense_edit(action, membership.sense, list_id: membership.word_list_id, **)
  end

  def front_matter_of(snippet)
    tokens = [{ "text" => "花" }]
    create(:front_matter, source: snippet.source, body: "花", tokens:)
  end

  def file_in(dir, name, entry)
    file(File.join(dir, name), [], entries: [entry])
  end

  def revise_then_remove(sense)
    [sense_edit("revise", sense, gloss: "blossom"), sense_edit("remove", sense)]
  end

  def used(sense, **)
    tokens = [{ "text" => "花", "sense_id" => sense.id }]
    create(:snippet_sentence, body: "花", tokens:, **)
  end

  describe ".apply" do
    it "revises a sense" do
      sense = create(:sense, gloss: "to spend / flower")

      apply(sense_edit("revise", sense, gloss: "flower"))

      expect(sense.reload.gloss).to eq("flower")
    end

    it "adds a sense in the file's language" do
      apply({ action: "add", headword: "casa", gloss: "house" }, language: "pt")

      expect(Sense.sole.entry.language).to eq("pt")
    end

    it "gives an added sense its traditional form" do
      apply(added(traditional: "髮"))

      expect(Sense.sole.traditional).to eq("髮")
    end

    it "names the senses it adds as new 0, new 1…" do
      list = create(:word_list)

      apply(added, { action: "attach", sense: "new 0", list_id: list.id })

      expect(list.senses.sole.gloss).to eq("hair")
    end

    it "removes a sense" do
      sense = create(:sense)

      expect { apply(sense_edit("remove", sense)) }.to delete_record(sense)
    end

    it "attaches a sense to a list under a category" do
      sense = create(:sense)
      list = create(:word_list)

      apply(sense_edit("attach", sense, list_id: list.id, category: "noun"))

      expect(list.sense_memberships.sole.category).to eq("noun")
    end

    it "detaches a sense from a list" do
      membership = create(:sense_membership)

      expect { apply(list_edit("detach", membership)) }
        .to delete_record(membership)
    end

    it "recategorizes a sense in a list" do
      membership = create(:sense_membership, category: "verb")

      apply(list_edit("recategorize", membership, category: "noun"))

      expect(membership.reload.category).to eq("noun")
    end

    it "repoints a token" do
      sentence = used(create(:sense), snippet: create(:snippet))
      other = create(:sense)
      llm.answer(categories: [{ id: 0, category: "noun" }])

      repointed(sentence, other)

      expect(sentence.reload.tokens.sole["sense_id"]).to eq(other.id)
    end

    it "finishes a repointed token's snippet again" do
      sentence = used(create(:sense), snippet: create(:snippet))
      llm.answer(categories: [{ id: 0, category: "noun" }])

      repointed(sentence, create(:sense))

      expect(sentence.snippet.reload.status).to eq(:finished)
    end

    it "finishes the source's first snippet for its front matter" do
      snippet = create(:snippet)
      llm.answer(categories: [{ id: 0, category: "noun" }])

      repointed(front_matter_of(snippet), create(:sense))

      expect(snippet.word_list.senses.count).to eq(1)
    end

    it "runs the edits given in place of the file's" do
      sense = create(:sense, gloss: "flower")
      path = suggestion_file([sense_edit("revise", sense, gloss: "blossom")])

      described_class.apply(path, 0, edits: [sense_edit("remove", sense)])

      expect(Sense.exists?(sense.id)).to be(false)
    end

    it "applies all of a suggestion's edits or none" do
      sense = create(:sense, gloss: "flower")
      used(sense)

      suppress(Compendium::Edit::Refused) { apply(*revise_then_remove(sense)) }

      expect(sense.reload.gloss).to eq("flower")
    end

    it "refuses an action it does not know" do
      expect { apply({ action: "run" }) }
        .to raise_error(ArgumentError, "Unknown edit: run")
    end

    it "refuses once a sense of the file's entries has changed" do
      sense = create(:sense, gloss: "flower")
      path = suggestion_file([], entries: [sense.entry])
      sense.update!(gloss: "blossom")

      expect { described_class.apply(path, 0) }
        .to raise_error(described_class::Stale)
    end

    it "refuses once an entry of the file is gone" do
      entry = create(:entry)
      path = suggestion_file([], entries: [entry])
      entry.destroy!

      expect { described_class.apply(path, 0) }
        .to raise_error(described_class::Stale)
    end

    it "takes the suggestion out of its file" do
      path = suggestion_file([], [{ action: "remove", sense: "1" }])

      described_class.apply(path, 0)

      expect(described_class.read(path)["suggestions"].sole["edits"].size)
        .to eq(1)
    end

    it "deletes the file with its last suggestion" do
      path = suggestion_file([])

      described_class.apply(path, 0)

      expect(File.exist?(path)).to be(false)
    end

    it "keeps the rest of the file fresh after its own edits" do
      sense = create(:sense, gloss: "flower")
      revise = sense_edit("revise", sense, gloss: "blossom")
      path = suggestion_file([revise], [], entries: [sense.entry])

      described_class.apply(path, 0)

      expect(described_class.stale(Pathname(File.dirname(path)))).to be_empty
    end
  end

  describe ".dismiss" do
    it "takes the suggestion out without running it" do
      sense = create(:sense)
      path = suggestion_file([sense_edit("remove", sense)], [])

      described_class.dismiss(path, 0)

      expect(Sense.exists?(sense.id)).to be(true)
    end
  end

  describe ".stale" do
    it "lists the files whose entries have changed" do
      sense = create(:sense)
      dir = Dir.mktmpdir
      stale = file_in(dir, "zh-1.json", sense.entry)
      file_in(dir, "zh-2.json", create(:entry)) && sense.update!(gloss: "x")

      expect(described_class.stale(Pathname(dir))).to eq([stale])
    end
  end
end
