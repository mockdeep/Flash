# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Finish do
  def snippet_with(*tokens)
    snippet = create(:snippet)
    create(:snippet_sentence, snippet:, tokens:)
    snippet
  end

  def front_matter_snippet(*tokens)
    snippet = snippet_with
    create(:front_matter, source: snippet.source, tokens:)
    snippet
  end

  def resolved(sense, **working)
    { "text" => "爱", "sense_id" => sense.id, **working.stringify_keys }
  end

  def finish_despite_refusal(snippet)
    described_class.call(snippet)
  rescue described_class::Unfinished
    nil
  end

  def file_everything_as_verbs
    llm.respond do |call|
      ids = JSON.parse(call.prompt).pluck("id")
      { categories: ids.map { |id| { id:, category: "verb" } } }
    end
  end

  describe ".call" do
    it "puts a traditional text's spelling on its senses" do
      file_everything_as_verbs
      sense = create(:sense)
      token = resolved(sense, text: "愛", headword: "爱")
      described_class.call(snippet_with(token))

      expect(sense.reload.traditional).to eq("愛")
    end

    it "strips the pipeline's working keys" do
      file_everything_as_verbs
      sense = create(:sense)
      snippet = snippet_with(resolved(sense, outcome: "created", note: "?"))
      described_class.call(snippet)

      expect(snippet.reload.status).to eq(:finished)
    end

    it "adds the snippet's senses to its word_list" do
      file_everything_as_verbs
      sense = create(:sense)
      snippet = snippet_with(resolved(sense, outcome: "matched"))
      described_class.call(snippet)

      expect(snippet.word_list.senses).to eq([sense])
    end

    it "finishes its source's front matter" do
      file_everything_as_verbs
      token = resolved(create(:sense), outcome: "matched")
      snippet = front_matter_snippet(token)
      described_class.call(snippet)

      expect(snippet.source.front_matter.sole.status).to eq(:finished)
    end

    it "adds its source's front matter senses to its word_list" do
      file_everything_as_verbs
      sense = create(:sense)
      snippet = front_matter_snippet(resolved(sense))
      described_class.call(snippet)

      expect(snippet.word_list.senses).to eq([sense])
    end

    it "files the list's new memberships by category" do
      file_everything_as_verbs
      snippet = snippet_with(resolved(create(:sense)))
      described_class.call(snippet)

      expect(snippet.word_list.sense_memberships.pluck(:category))
        .to eq(["verb"])
    end

    it "files them in batches" do
      file_everything_as_verbs
      stub_const("Snippets::Finish::CATEGORIZE_BATCH", 1)
      tokens = create_pair(:sense).map { resolved(it) }
      described_class.call(snippet_with(*tokens))

      expect(llm.calls.size).to eq(2)
    end

    it "finishes a snippet with a skipped word" do
      snippet = snippet_with({ "text" => "爱", "skip" => "foreign" })
      described_class.call(snippet)

      expect(snippet.reload.status).to eq(:finished)
    end

    it "refuses while a Chinese word has no sense" do
      snippet = snippet_with({ "text" => "爱", "outcome" => "unresolved" })

      expect { described_class.call(snippet) }
        .to raise_error(described_class::Unfinished, /without a sense: 爱/)
    end

    it "changes nothing when it refuses" do
      tokens = [{ "text" => "爱", "outcome" => "unresolved", "note" => "?" }]
      snippet = snippet_with(*tokens)

      expect { finish_despite_refusal(snippet) }
        .not_to change(SenseMembership, :count)
    end
  end
end
