# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Process do
  # A whole pipeline in miniature: segments each sentence by character,
  # proposes a new sense for every occurrence, and accepts every proposal.
  def fake_pipeline
    llm.respond do |call|
      prompt = JSON.parse(call.prompt)

      case call.system
      when Snippets::Segment::SYSTEM then segmented(prompt)
      when Snippets::Propose::SYSTEM then proposed(prompt)
      else judged(prompt)
      end
    end
  end

  def segmented(prompt)
    sentences =
      prompt.map do |row|
        words = row["sentence"].chars.map { { text: it, simplified: it } }
        { id: row["id"], words: }
      end
    { sentences: }
  end

  def judged(prompt)
    { verdicts: prompt["occurrences"].map { { id: it["id"], accept: true } } }
  end

  def proposed(prompt)
    decisions =
      prompt["occurrences"].map do |occurrence|
        gloss = "gloss of #{occurrence["word"]}"
        { id: occurrence["id"], decision: "new", reading: "zì", gloss: }
      end
    { decisions: }
  end

  def calls_to(system) = llm.calls.count { it.system == system }

  def segmented_sentence(body = "我")
    create(:snippet_sentence, body:, tokens: [{ "text" => body }])
  end

  describe ".call" do
    it "segments and resolves a new sentence" do
      fake_pipeline
      sentence = create(:snippet_sentence, body: "我爱你")
      described_class.call

      expect(sentence.reload.tokens.pluck("outcome")).to all(eq("created"))
    end

    it "resolves a sentence segmented earlier without segmenting it" do
      fake_pipeline
      segmented_sentence
      described_class.call

      expect(calls_to(Snippets::Segment::SYSTEM)).to eq(0)
    end

    it "leaves resolved sentences alone" do
      tokens = [{ "text" => "我", "sense_id" => 1 }]
      create(:snippet_sentence, tokens:)
      described_class.call

      expect(llm.calls).to be_empty
    end

    it "segments in batches" do
      fake_pipeline
      stub_const("Snippets::Process::SEGMENT_BATCH", 1)
      create_pair(:snippet_sentence, body: "我")
      described_class.call

      expect(calls_to(Snippets::Segment::SYSTEM)).to eq(2)
    end

    it "resolves in batches" do
      fake_pipeline
      stub_const("Snippets::Process::RESOLVE_BATCH", 1)
      2.times { segmented_sentence }
      described_class.call

      expect(calls_to(Snippets::Propose::SYSTEM)).to eq(2)
    end

    it "yields each step and the batch it finished" do
      fake_pipeline
      sentence = create(:snippet_sentence, body: "我")

      expect { |block| described_class.call(&block) }.to yield_successive_args(
        [:segmented, [sentence]], [:resolved, [sentence]]
      )
    end
  end
end
