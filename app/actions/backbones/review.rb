# frozen_string_literal: true

module Backbones
  # A fresh reader's verdict on a draft, from Opus, which sees the draft,
  # the version it was written from and the original, but nothing of how
  # the draft was written.
  module Review
    Problem = Data.define(:quote, :category, :why, :replacement)
    Result = Data.define(:verdict, :problems)

    class Result
      def pass? = verdict == "PASS"
    end

    SYSTEM = <<~TEXT
      You review a graded-reader retelling of one chapter of %<work>s by
      %<author>s for learners of %<language>s. It is one rung of a ladder of
      retellings that runs from the first level up to the original, written
      from the version one level up, and shorter, so it leaves details out on
      purpose. Read it as an experienced native-speaking teacher and editor
      of graded readers would.

      The vocabulary has been checked mechanically against the level's word
      lists, so don't police single words; names, titles before a name and
      the story words listed are allowed on purpose. Check:
      1. Naturalness within the level: stiff phrasing, translationese, wrong
         collocations, monotonous rhythm or sentence openings. Simple is
         good; childish or unnatural is not.
      2. Grammar and sentence length for the level, as its guidelines say.
      3. Errors: grammar, agreement, spelling, punctuation.
      4. Story: anything lost or garbled that makes it confusing next to the
         fuller versions, above all a line that depends on a setup that was
         cut (who someone is, why something happens, who is speaking, why a
         reaction makes sense), or a fact that goes against the original. A
         detail simply left out is fine unless the story needs it.
      5. The title: right for the level, as its guidelines say, and its
         English translation right.

      Give a verdict, PASS or REWORK, and real problems only, each with the
      quote, its category, why it is a problem (in English) and a
      replacement as simple as the text around it.
    TEXT

    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["verdict", "problems"],
      properties: {
        verdict: { type: "string", enum: ["PASS", "REWORK"] },
        problems: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["quote", "category", "why", "replacement"],
            properties: {
              quote: { type: "string" },
              category: { type: "string" },
              why: { type: "string" },
              replacement: { type: "string" },
            },
          },
        },
      },
    }.freeze

    def self.call(backbone, level, chapter, draft)
      answer = Llm.client.call(
        model: Llm::OPUS,
        system: format(SYSTEM, **backbone.prompt_terms),
        prompt: prompt(backbone, level, chapter, draft).to_json,
        schema: SCHEMA,
      )
      problems = answer["problems"].map { Problem.new(**it.symbolize_keys) }

      Result.new(verdict: answer["verdict"], problems:)
    end

    def self.prompt(backbone, level, chapter, draft)
      original = {
        title: backbone.heading_title(Backbone::ORIGINAL, chapter),
        text: backbone.original_path(chapter).read,
      }

      Draft.brief(backbone, level, chapter).merge(original:, draft: draft.to_h)
    end
  end
end
