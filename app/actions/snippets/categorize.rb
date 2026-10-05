# frozen_string_literal: true

module Snippets
  # Files a list's uncategorized memberships under a part of speech, which
  # is what study draws same-category distractors from. The gloss settles
  # it, so no sentence is sent and nothing is judged: a wrong category only
  # dulls a card's options. Every membership given leaves with a category,
  # so the step cannot be asked the same question twice.
  module Categorize
    CATEGORIES = [
      "noun",
      "verb",
      "adjective",
      "adverb",
      "pronoun",
      "conjunction",
      "preposition",
      "particle",
      "measure word",
      "numeral",
      "proper noun",
      "idiom",
      "phrase",
      "other",
    ].freeze
    UNFILED = "other"
    SYSTEM = <<~TEXT
      You file Chinese vocabulary by part of speech. Each item gives a
      headword, its reading and one English gloss; choose the category that
      fits the word in that meaning. Use "proper noun" for names of people,
      places and works, "idiom" for chengyu and set sayings, "phrase" for a
      multi-word expression that is none of the others, and "other" only
      when nothing else fits.
    TEXT
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
              category: { type: "string", enum: CATEGORIES },
            },
          },
        },
      },
    }.freeze
    ASK = {
      list: "categories", model: Llm::SONNET, system: SYSTEM, schema: SCHEMA
    }.freeze

    def self.call(memberships)
      prompt = memberships.each_with_index.map { |one, id| prompt(one, id) }
      rows = Llm::AskEach.call(memberships, prompt:, **ASK)

      memberships.each_with_index do |membership, id|
        membership.update!(category: rows.dig(id, "category") || UNFILED)
      end
    end

    def self.prompt(membership, id)
      sense = membership.sense
      entry = sense.entry

      {
        id:,
        headword: entry.headword,
        reading: entry.reading,
        gloss: sense.gloss,
      }
    end
  end
end
