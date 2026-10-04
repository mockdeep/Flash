# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Judge do
  def proposal(word = "爱")
    tokens = [{ "text" => word }]
    sentence = build(:snippet_sentence, body: word, tokens:)
    occurrence = Snippets::Occurrence.new(sentence:, index: 0)
    Snippets::Proposal.new(occurrence, "new", 0, "ài", "to love", "")
  end

  def briefing_for(proposal)
    proposed = [proposal.proposed]
    Snippets::Briefing.call([proposal.occurrence], proposed:)
  end

  def verdict(id, accept:, reason: "fits the sentence")
    { id:, accept:, reason: }
  end

  def judge(proposals)
    described_class.call(proposals, model: Llm::OPUS)
  end

  describe ".call" do
    it "asks nothing when there are no proposals" do
      expect(judge([])).to eq([])
    end

    it "asks the given model" do
      llm.answer({ verdicts: [] })

      judge([proposal])

      expect(llm.calls.sole.model).to eq("claude-opus-5-5")
    end

    it "asks about every proposal in one briefing" do
      llm.answer({ verdicts: [] })
      judged = proposal
      briefing = briefing_for(judged).to_json
      judge([judged])

      expect(llm.calls.sole.prompt).to eq(briefing)
    end

    it "notes a rejection that came without a reason" do
      rejected = proposal
      llm.answer({ verdicts: [{ id: 0, accept: false }] })

      judge([rejected])

      expect(rejected.occurrence.rejection).to eq("rejected without a reason")
    end

    it "accepts a verdict that gives no reason" do
      accepted = proposal
      llm.answer({ verdicts: [{ id: 0, accept: true }] })

      expect(judge([accepted])).to eq([accepted])
    end

    it "returns the proposals the judge accepts" do
      proposals = [proposal("爱"), proposal("你")]
      verdicts = [verdict(0, accept: false), verdict(1, accept: true)]
      llm.answer({ verdicts: })

      expect(judge(proposals)).to eq([proposals.last])
    end

    it "records the judge's reason on a rejected occurrence" do
      rejected = proposal
      verdicts = [verdict(0, accept: false, reason: "wrong tone")]
      llm.answer({ verdicts: })

      judge([rejected])

      expect(rejected.occurrence.rejection).to eq("wrong tone")
    end

    it "leaves an accepted occurrence without a rejection" do
      accepted = proposal
      llm.answer({ verdicts: [verdict(0, accept: true)] })

      judge([accepted])

      expect(accepted.occurrence.rejection).to be_nil
    end

    it "rejects a proposal the judge leaves out" do
      unjudged = proposal
      llm.answer({ verdicts: [] })

      judge([unjudged])

      expect(unjudged.occurrence.rejection).to eq("no verdict was returned")
    end
  end
end
