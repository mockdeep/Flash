# frozen_string_literal: true

module Snippets
  # The proposing tier: for each occurrence, pick an existing sense, propose
  # a new one, or call the token missegmented. A decision that breaks the
  # rules is turned into a rejection, so the occurrence goes up to the next
  # rung like any other.
  module Propose
    DECISIONS = ["existing", "new", "missegmented"].freeze
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["decisions"],
      properties: {
        decisions: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "decision"],
            properties: {
              id: { type: "integer" },
              decision: { type: "string", enum: DECISIONS },
              sense_id: { type: "integer" },
              reading: { type: "string" },
              gloss: { type: "string" },
              note: { type: "string" },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "decisions", schema: SCHEMA }.freeze

    def self.call(occurrences, model:, language:)
      prompt = Briefing.call(occurrences)
      system = language.prompts.propose
      rows = Llm::AskEach.call(occurrences, prompt:, model:, system:, **ASK)

      occurrences.each_with_index.filter_map do |occurrence, id|
        proposal(occurrence, rows[id])
      end
    end

    def self.proposal(occurrence, row)
      proposal = Proposal.from(occurrence, row || {})
      occurrence.rejection =
        row ? proposal.problem : "no decision was returned"
      proposal unless occurrence.rejection
    end
  end
end
