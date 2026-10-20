# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Process do
  # A whole pipeline in miniature: segments each sentence by character,
  # proposes a new sense for every occurrence, and accepts every proposal.
  def fake_pipeline
    llm.respond { |call| pipeline_answer(call) }
  end

  def pipeline_answer(call)
    prompt = JSON.parse(call.prompt)

    case call.system
    when Language::MANDARIN.prompts.segment then segmented(prompt)
    when Language::MANDARIN.prompts.propose then proposed(prompt)
    else judged(prompt)
    end
  end

  # Calls the first word it is asked about missegmented, then runs as the
  # fake pipeline does.
  def missegmenting_pipeline
    faulted = false
    llm.respond do |call|
      proposing = call.system == Language::MANDARIN.prompts.propose
      next pipeline_answer(call) if faulted || !proposing

      faulted = true
      note = "joins 花 and 了"
      { decisions: [{ id: 0, decision: "missegmented", note: }] }
    end
  end

  def reported_lines = [].tap { |lines| described_class.call { lines << it } }

  def segmented(prompt)
    sentences =
      prompt.map do |row|
        words =
          row["sentence"].chars.map do |char|
            { text: char, simplified: char, traditional: char }
          end
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

  def portuguese_sentence(**)
    word_list = create(:word_list, language: "pt")
    create(:snippet_sentence, snippet: create(:snippet, word_list:), **)
  end

  # Answers every step with nothing, so only what was asked is checked.
  def silent_pipeline
    llm.respond { { sentences: [], decisions: [], verdicts: [] } }
  end

  def first_prompt = JSON.parse(llm.calls.first.prompt)

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

      expect(calls_to(Language::MANDARIN.prompts.segment)).to eq(0)
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

      expect(calls_to(Language::MANDARIN.prompts.segment)).to eq(2)
    end

    it "resolves in batches" do
      fake_pipeline
      stub_const("Snippets::Process::RESOLVE_BATCH", 1)
      2.times { segmented_sentence }
      described_class.call

      expect(calls_to(Language::MANDARIN.prompts.propose)).to eq(2)
    end

    it "segments one language at a time" do
      silent_pipeline
      create(:snippet_sentence, body: "我")
      portuguese_sentence(body: "Olá.")
      described_class.call

      expect(first_prompt.pluck("sentence")).to eq(["我"])
    end

    it "resolves one language at a time" do
      silent_pipeline
      segmented_sentence
      portuguese_sentence(body: "Olá", tokens: [{ "text" => "Olá" }])
      described_class.call

      expect(first_prompt["sentences"].pluck("text")).to eq(["我"])
    end

    it "segments only the sentences given" do
      silent_pipeline
      create(:snippet_sentence, body: "我")
      sentence = create(:snippet_sentence, body: "你")
      described_class.call(sentences: SnippetSentence.where(id: sentence))

      expect(first_prompt.pluck("sentence")).to eq(["你"])
    end

    it "resolves only the sentences given" do
      silent_pipeline
      segmented_sentence("我")
      sentence = segmented_sentence("你")
      described_class.call(sentences: SnippetSentence.where(id: sentence))

      expect(first_prompt["sentences"].pluck("text")).to eq(["你"])
    end

    it "reports each batch it finishes" do
      fake_pipeline
      snippet = create(:snippet, source: create(:source, title: "T"))
      create(:snippet_sentence, body: "我", snippet:)

      expect(reported_lines)
        .to eq(["Segmented 1 sentences of T", "Resolved 1 sentences of T"])
    end

    it "reports a sentence sent back to the segmenter" do
      missegmenting_pipeline
      create(:snippet_sentence, body: "花了", tokens: [{ "text" => "花了" }])

      expect(reported_lines).to include("Re-segmented 花了 (花了: joins 花 and 了)")
    end
  end
end
