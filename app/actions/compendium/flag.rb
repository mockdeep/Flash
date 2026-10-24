# frozen_string_literal: true

module Compendium
  # The refiner's first look at a batch: Sonnet suggests a fix for each
  # problem it finds, under the headword it belongs to. Nothing is kept on
  # its say-so; Confirm decides.
  module Flag
    ACTIONS = [
      "revise",
      "add",
      "remove",
      "attach",
      "detach",
      "recategorize",
      "repoint",
    ].freeze
    PROBLEMS = [
      "merged",
      "duplicate",
      "gloss",
      "reading",
      "traditional",
      "category",
      "wrong_pick",
    ].freeze
    EDIT = {
      type: "object",
      additionalProperties: false,
      required: ["action"],
      properties: {
        action: { enum: ACTIONS },
        sense: { type: "string" },
        headword: { type: "string" },
        reading: { type: "string" },
        gloss: { type: "string" },
        article: { type: "string" },
        traditional: { type: "string" },
        list_id: { type: "integer" },
        category: { type: "string" },
        sentence_id: { type: "integer" },
        token: { type: "integer" },
      },
    }.freeze
    SUGGESTION = {
      type: "object",
      additionalProperties: false,
      required: [
        "headword", "problem", "reason", "examples", "confidence", "edits"
      ],
      properties: {
        headword: { type: "string" },
        problem: { enum: PROBLEMS },
        reason: { type: "string" },
        examples: { type: "array", items: { type: "string" } },
        confidence: { enum: ["high", "medium"] },
        edits: { type: "array", items: EDIT },
      },
    }.freeze
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["suggestions"],
      properties: { suggestions: { type: "array", items: SUGGESTION } },
    }.freeze

    def self.call(prompt, language:)
      system = RefinePrompts.flag(language)
      answer = Llm.client.call(
        model: Llm::SONNET, system:, prompt: prompt.to_json, schema: SCHEMA,
      )

      answer["suggestions"]
    end
  end
end
