# frozen_string_literal: true

module Snippets
  # The judging tier: nothing enters the compendium on one model's say-so.
  # Returns the proposals it accepts; a rejected proposal's occurrence keeps
  # the judge's reason.
  module Judge
    UNREASONED = "rejected without a reason"
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["verdicts"],
      properties: {
        verdicts: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "accept"],
            properties: {
              id: { type: "integer" },
              accept: { type: "boolean" },
              reason: { type: "string" },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "verdicts", schema: SCHEMA }.freeze
    UNJUDGED = {
      "accept" => false,
      "reason" => "no verdict was returned",
    }.freeze

    def self.call(proposals, model:, language:)
      occurrences = proposals.map(&:occurrence)
      prompt = Briefing.call(occurrences, proposed: proposals.map(&:proposed))
      system = language.prompts.judge
      verdicts = Llm::AskEach.call(proposals, prompt:, model:, system:, **ASK)

      proposals.each_with_index.filter_map do |proposal, id|
        judged(proposal, verdicts.fetch(id, UNJUDGED))
      end
    end

    def self.judged(proposal, verdict)
      occurrence = proposal.occurrence
      occurrence.rejection =
        verdict["accept"] ? nil : verdict["reason"].presence || UNREASONED
      proposal unless occurrence.rejection
    end
  end
end
