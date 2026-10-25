# frozen_string_literal: true

module Snippets
  # Files a list's uncategorized memberships under a part of speech, which
  # is what study draws same-category distractors from. The gloss settles
  # it, so no sentence is sent and nothing is judged: a wrong category only
  # dulls a card's options. Every membership given leaves with a category,
  # so the step cannot be asked the same question twice.
  module Categorize
    UNFILED = "other"
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["categories"],
      properties: {
        categories: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "category"],
            properties: {
              id: { type: "integer" },
              category: { type: "string" },
            },
          },
        },
      },
    }.freeze

    def self.call(memberships, language)
      prompt = memberships.each_with_index.map { |one, id| prompt(one, id) }
      rows = Llm::AskEach.call(memberships, prompt:, **ask(language))

      memberships.each_with_index do |membership, id|
        membership.update!(category: rows.dig(id, "category") || UNFILED)
      end
    end

    # Each language files its words under its own categories.
    def self.ask(language)
      category = { enum: language.lexicon.categories }
      schema = SCHEMA.deep_merge(
        properties: { categories: { items: { properties: { category: } } } },
      )

      { list: "categories", model: Llm::SONNET, system: language.prompts.categorize, schema: }
    end

    def self.prompt(membership, id)
      sense = membership.sense
      entry = sense.entry

      {
        id:,
        headword: entry.term,
        reading: entry.reading,
        gloss: sense.gloss,
      }
    end
  end
end
