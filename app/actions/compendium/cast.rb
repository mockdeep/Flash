# frozen_string_literal: true

module Compendium
  # Who is who in a source: its narrator and characters, each with a
  # gender, so a review of one sentence knows that the "disse" there is
  # "he said". Built a finished snippet at a time, each call handed the
  # note so far, since a novel is too long to read in one. Nil for a source
  # with no finished snippet.
  module Cast
    SYSTEM = <<~TEXT
      You keep a cast list for a text a language learner is studying, so
      that reviewers checking word glosses one sentence at a time know who
      is who. You are given the text's title and author, the cast list so
      far (none at first), and the next section of the text.

      Return the cast list updated with that section: add the characters
      who appear in it, and correct earlier entries the section shows to be
      wrong. Keep it a cast list, not a plot summary. For each character
      give their name (or how the text refers to them, if unnamed), their
      gender, and in a few words who they are. Say who narrates and in
      which person, or that no character does. Include only what the text
      itself shows.
    TEXT
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["narrator", "characters"],
      properties: {
        narrator: { type: "string" },
        characters: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["name", "gender", "about"],
            properties: {
              name: { type: "string" },
              gender: { enum: ["male", "female", "group", "unknown"] },
              about: { type: "string" },
            },
          },
        },
      },
    }.freeze
    ASK = { model: Llm::SONNET, system: SYSTEM, schema: SCHEMA }.freeze

    def self.call(source)
      finished = source.snippets.select { it.status == :finished }

      finished.reduce(nil) do |note, snippet|
        prompt = { source: credit(source), note:, snippet: text(snippet) }

        Llm.client.call(prompt: prompt.to_json, **ASK)
      end
    end

    def self.credit(source) = { title: source.title, author: source.author }

    def self.text(snippet) = { heading: snippet.heading, body: snippet.body }
  end
end
