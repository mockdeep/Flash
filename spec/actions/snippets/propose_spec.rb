# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Propose do
  def occurrence(word = "爱")
    tokens = [{ "text" => word }]
    sentence = build(:snippet_sentence, body: word, tokens:)
    Snippets::Occurrence.new(sentence:, index: 0)
  end

  def decision(id, gloss: "to love")
    fields = { sense_id: 0, headword: "", reading: "ài", gloss:, note: "" }
    { id:, decision: "new", **fields }
  end

  def propose(occurrences)
    described_class.call(occurrences, model: Llm::SONNET)
  end

  describe ".call" do
    it "asks nothing when there are no occurrences" do
      expect(propose([])).to eq([])
    end

    it "asks the given model" do
      llm.answer({ decisions: [] })

      propose([occurrence])

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "asks about every occurrence in one briefing" do
      llm.answer({ decisions: [] })
      occurrences = [occurrence("爱"), occurrence("你")]
      briefing = Snippets::Briefing.call(occurrences).to_json
      propose(occurrences)

      expect(llm.calls.sole.prompt).to eq(briefing)
    end

    it "takes a decision that leaves out the fields it does not use" do
      sense = create(:sense, entry: create(:entry, headword: "爱"))
      existing = { id: 0, decision: "existing", sense_id: sense.id }
      llm.answer({ decisions: [existing] })

      expect(propose([occurrence]).map(&:sense_id)).to eq([sense.id])
    end

    it "matches each decision to its occurrence by id" do
      occurrences = [occurrence("爱"), occurrence("你")]
      llm.answer({ decisions: [decision(1, gloss: "you"), decision(0)] })

      proposals = propose(occurrences)

      expect(proposals.map(&:occurrence)).to eq(occurrences)
    end

    it "carries each decision's content" do
      llm.answer({ decisions: [decision(1, gloss: "you"), decision(0)] })

      proposals = propose([occurrence("爱"), occurrence("你")])

      expect(proposals.map(&:gloss)).to eq(["to love", "you"])
    end

    it "leaves out a decision that breaks the rules" do
      llm.answer({ decisions: [decision(0, gloss: "")] })

      expect(propose([occurrence])).to eq([])
    end

    it "turns a broken rule into the occurrence's rejection" do
      waiting = occurrence
      llm.answer({ decisions: [decision(0, gloss: "")] })

      propose([waiting])

      expect(waiting.rejection)
        .to eq("a new sense needs both a reading and a gloss")
    end

    it "rejects an occurrence the answer leaves out" do
      waiting = occurrence
      llm.answer({ decisions: [] })

      propose([waiting])

      expect(waiting.rejection).to eq("no decision was returned")
    end

    it "clears an earlier rejection once a proposal stands" do
      waiting = occurrence
      waiting.rejection = "wrong reading"
      llm.answer({ decisions: [decision(0)] })

      propose([waiting])

      expect(waiting.rejection).to be_nil
    end
  end
end
