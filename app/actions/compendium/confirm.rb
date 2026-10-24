# frozen_string_literal: true

module Compendium
  # Opus keeps or drops each suggestion Flag made, seeing the same batch.
  # It cannot amend one: a suggestion it disagrees with is dropped, and the
  # entry comes round again next cycle. One it gives no verdict on is
  # dropped too. A kept suggestion carries Opus's reason as `confirmed`.
  module Confirm
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
            required: ["id", "keep"],
            properties: {
              id: { type: "integer" },
              keep: { type: "boolean" },
              reason: { type: "string" },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "verdicts", model: Llm::OPUS, schema: SCHEMA }.freeze

    def self.call(suggestions, prompt:, language:)
      numbered = suggestions.each_with_index.map { |one, id| { id:, **one } }
      prompt = { **prompt, suggestions: numbered }
      system = RefinePrompts.confirm(language)
      verdicts = Llm::AskEach.call(suggestions, prompt:, system:, **ASK)

      suggestions.each_with_index.filter_map do |suggestion, id|
        verdict = verdicts.fetch(id, {})
        suggestion.merge("confirmed" => verdict["reason"]) if verdict["keep"]
      end
    end
  end
end
