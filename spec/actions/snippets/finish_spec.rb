# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Finish do
  def snippet_with(*tokens)
    snippet = create(:snippet)
    create(:snippet_sentence, snippet:, tokens:)
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
