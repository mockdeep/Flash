# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Resolve do
  def sentence(words = ["爱"])
    tokens = words.map { |word| { "text" => word } }
    create(:snippet_sentence, body: words.join, tokens:)
  end

  def decision(id, decision = "new", sense_id: 0, gloss: "to love")
    fields = { sense_id:, headword: "", reading: "ài", gloss:, note: "" }
    { id:, decision:, **fields }
  end

  def decisions(*, **) = { decisions: [decision(0, *, **)] }

  # Answers every request with no decisions, keeping what each one asked.
  def record_marked_prompts
    [].tap do |asked|
      llm.respond do |call|
        asked << JSON.parse(call.prompt)["occurrences"].pluck("marked")
        { decisions: [] }
      end
    end
  end

  # Proposes a new sense for a word that lists none, picks the listed sense
  # otherwise, and accepts every proposal.
  def claude_reusing_senses
    llm.respond do |call|
      briefing = JSON.parse(call.prompt)
      next verdicts(true) if briefing["occurrences"].first["gloss"]

      sense = briefing["words"].first["senses"].first
      sense ? decisions("existing", sense_id: sense["id"]) : decisions
    end
  end

  # One "existing" decision per token, in order, each on its own sense.
  def existing_decisions(senses)
    { decisions: senses.map.with_index { |sense, id| existing(id, sense) } }
  end

  def existing(id, sense) = decision(id, "existing", sense_id: sense.id)

  def verdicts(accept, reason: "not what it means here")
    { verdicts: [{ id: 0, accept:, reason: }] }
  end

  def resolved_token(sentence)
    described_class.call([sentence])
    sentence.reload.tokens.first
  end

  def outcomes(sentence) = sentence.reload.tokens.pluck("outcome")

  describe ".call" do
    it "leaves tokens without a Han character alone, without asking" do
      expect(resolved_token(sentence(["。"]))).to eq("text" => "。")
    end

    it "records an existing sense without asking the judge" do
      sense = create(:sense, entry: create(:entry, headword: "爱"))
      llm.answer(decisions("existing", sense_id: sense.id))

      expect(resolved_token(sentence))
        .to include("outcome" => "matched", "sense_id" => sense.id)
    end

    it "records a new sense the judge accepts" do
      llm.answer(decisions, verdicts(true))

      expect(resolved_token(sentence))
        .to include("outcome" => "created", "sense_id" => Sense.last&.id)
    end

    it "has Opus judge Sonnet's proposal" do
      llm.answer(decisions, verdicts(true))

      described_class.call([sentence])

      expect(llm.calls.map(&:model))
        .to eq(["claude-sonnet-5-5", "claude-opus-5-5"])
    end

    context "when the judge rejects the first proposal" do
      it "records the second rung's proposal once accepted" do
        second = decisions(gloss: "to be fond of")
        llm.answer(decisions, verdicts(false), second, verdicts(true))

        described_class.call([sentence])

        expect(Sense.pluck(:gloss)).to eq(["to be fond of"])
      end

      it "has Opus propose on the second rung" do
        llm.answer(decisions, verdicts(false), decisions, verdicts(true))

        described_class.call([sentence])

        expect(llm.calls.map(&:model).count("claude-opus-5-5")).to eq(3)
      end

      it "shows the second proposer the rejection" do
        rejected = verdicts(false, reason: "wrong tone")
        llm.answer(decisions, rejected, decisions, verdicts(true))
        described_class.call([sentence])

        expect(llm.calls.third.prompt).to include('"rejection":"wrong tone"')
      end

      it "leaves the word unresolved when the top rung is rejected too" do
        rejected = verdicts(false, reason: "still wrong")
        llm.answer(decisions, verdicts(false), decisions, rejected)

        expect(resolved_token(sentence))
          .to include("outcome" => "unresolved", "note" => "still wrong")
      end

      it "creates no sense for an unresolved word" do
        llm.answer(decisions, verdicts(false), decisions, verdicts(false))

        expect { described_class.call([sentence]) }.not_to change(Sense, :count)
      end
    end

    context "when a token is missegmented" do
      def missegmented
        faulting = decision(0, "missegmented").merge(note: "joins 花 and 了")
        { decisions: [faulting] }
      end

      def resegmented(*words)
        words = words.map { |word| { text: word, simplified: word } }
        { sentences: [{ id: 0, words: }] }
      end

      def undecided = { decisions: [] }

      it "segments the sentence again" do
        faulted = sentence(["花了"])
        llm.answer(missegmented, resegmented("花", "了"), *[undecided] * 4)
        described_class.call([faulted])

        expect(faulted.reload.tokens.pluck("text")).to eq(["花", "了"])
      end

      it "gives the segmenter the complaint" do
        llm.answer(missegmented, resegmented("花", "了"), *[undecided] * 4)
        described_class.call([sentence(["花了"])])

        expect(llm.calls.second.prompt).to include("花了: joins 花 and 了")
      end

      it "returns the complaint" do
        faulted = sentence(["花了"])
        llm.answer(missegmented, resegmented("花", "了"), *[undecided] * 4)

        expect(described_class.call([faulted]))
          .to eq(faulted => "花了: joins 花 and 了")
      end

      it "leaves the token unresolved when it is faulted again" do
        llm.answer(missegmented, resegmented("花了"), missegmented)

        expect(resolved_token(sentence(["花了"])))
          .to include("outcome" => "unresolved", "note" => "joins 花 and 了")
      end
    end

    it "asks about each token of a repeated word" do
      asked = record_marked_prompts

      described_class.call([sentence(["花", "买", "花"])])

      expect(asked.first).to eq(["【花】买花", "花【买】花", "花买【花】"])
    end

    it "lets one word take two senses within a sentence" do
      senses = create_pair(:sense, entry: create(:entry, headword: "花"))
      llm.answer(existing_decisions(senses))
      repeating = sentence(["花", "花"])

      described_class.call([repeating])

      expect(repeating.reload.tokens.pluck("sense_id")).to eq(senses.map(&:id))
    end

    context "when a batch holds more tokens than one call takes" do
      it "asks about them a slice at a time" do
        stub_const("Snippets::Resolve::OCCURRENCE_BATCH", 2)
        asked = record_marked_prompts

        described_class.call([sentence(["花", "买", "花"])])

        expect(asked.map(&:size)).to eq([2, 2, 1, 1])
      end

      it "shows a later slice the senses an earlier one created" do
        stub_const("Snippets::Resolve::OCCURRENCE_BATCH", 1)
        claude_reusing_senses
        repeating = sentence(["爱", "爱"])

        described_class.call([repeating])

        expect(outcomes(repeating)).to eq(["created", "matched"])
      end
    end
  end
end
