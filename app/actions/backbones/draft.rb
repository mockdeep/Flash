# frozen_string_literal: true

module Backbones
  # One chapter at one level, written by Opus from the version one level up
  # (the original, for the top level), or a draft of it revised with
  # feedback: words above the level, or a reviewer's problems, which it
  # weighs rather than applies word for word.
  module Draft
    # A version of a chapter: its heading, the heading's English, its body.
    Text = Data.define(:title, :translation, :text)

    SYSTEM = <<~TEXT
      You retell one chapter of %<work>s by %<author>s for learners of
      %<language>s, at one level of a graded ladder of retellings that runs
      from the first level up to the original. You get the version one level
      up and write the chapter at this level from it, keeping its names and
      its wording where the level allows, so the versions stay close up the
      ladder.

      - Follow the level's guidelines and the book's notes.
      - Use words a learner at this level knows. Names, titles before a name
        and the story words listed pass at any level.
      - Keep as much of the version above as the guidelines say, and no
        more: what to leave out is part of the level.
      - Write natural %<language>s, as a native teacher would, and vary how
        sentences open.
      - Never cut a setup a later line depends on: who someone is, why
        something happens, who is speaking, why a reaction makes sense.
      - Keep every fact you keep true to the version above: names, numbers,
        who does what. A detail may be left out; none may be changed.
      - Lay out dialogue and quotation marks as the version above does.
      - title: the chapter's title at this level, as the guidelines say,
        without its number; translation: the title in plain English.

      When you get a draft and feedback, revise that draft: fix what the
      feedback raises and change nothing else. Use judgement: skip a
      suggestion that would bring in a word above the level or go against
      the version above, and find a simpler way to make its point.
    TEXT

    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["title", "translation", "text"],
      properties: {
        title: { type: "string" },
        translation: { type: "string" },
        text: { type: "string" },
      },
    }.freeze

    def self.call(backbone, level, chapter, revising: nil, feedback: nil)
      prompt = brief(backbone, level, chapter)
      prompt.merge!(draft: revising.to_h, feedback:) if revising
      answer = Llm.client.call(
        model: Llm::OPUS,
        system: format(SYSTEM, **backbone.prompt_terms),
        prompt: prompt.to_json,
        schema: SCHEMA,
      )

      Text.new(**answer.symbolize_keys)
    end

    # What a writer or reviewer needs to know about the level and the
    # version it is written from.
    def self.brief(backbone, level, chapter)
      {
        level: level.code,
        guidelines: level.guidelines,
        notes: backbone.notes,
        story_words: backbone.story_words(level),
        title_words: backbone.title_words,
        above: above(backbone, level, chapter),
      }
    end

    def self.above(backbone, level, chapter)
      version = backbone.above(level)&.code || Backbone::ORIGINAL

      {
        version:,
        title: backbone.heading_title(version, chapter),
        text: backbone.source_path(level, chapter).read,
      }
    end
  end
end
