# frozen_string_literal: true

module Snippets
  # Segments a batch of sentences into words, each with its simplified form
  # (the headword it studies under), kept on the token as `headword` only
  # where it differs.
  # The model sees the sentence, so it can pick by meaning where a
  # traditional character simplifies more than one way. The answer is
  # checked mechanically: the words must rejoin to the sentence's Han
  # characters, and each simplified form must be as long as its word. A
  # sentence that fails is asked again on its own, and one that fails twice
  # falls back to one token per character.
  module Segment
    WORD = {
      type: "object",
      additionalProperties: false,
      required: ["text", "simplified"],
      properties: {
        text: { type: "string" },
        simplified: { type: "string" },
      },
    }.freeze
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["sentences"],
      properties: {
        sentences: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "words"],
            properties: {
              id: { type: "integer" },
              words: { type: "array", items: WORD },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "sentences", model: Llm::SONNET, schema: SCHEMA }.freeze

    # `feedback` maps a sentence to what was wrong with its last
    # segmentation, for one sent back to be segmented again.
    def self.call(sentences, feedback: {})
      answers = ask(sentences, feedback)

      sentences.each_with_index do |sentence, id|
        tokens = tokens(sentence, answers[id], feedback)
        tokens = Recut.call(sentence, tokens) if feedback.key?(sentence)
        sentence.update!(tokens:)
      end
    end

    def self.tokens(sentence, row, feedback)
      words =
        verified(sentence, row) ||
        verified(sentence, ask([sentence], feedback).values.first) ||
        sentence.body.chars.map { |char| { "text" => char } }

      words.map { |word| token(*word.values_at("text", "simplified")) }
    end

    def self.token(text, simplified)
      return { "text" => text } if simplified.nil? || simplified == text

      { "text" => text, "headword" => simplified }
    end

    def self.ask(sentences, feedback)
      prompt =
        sentences.each_with_index.map do |sentence, id|
          { id:, sentence: sentence.body, **revision(sentence, feedback) }
        end

      system = sentences.first.language.prompts.segment
      Llm::AskEach.call(sentences, prompt:, system:, **ASK)
    end

    # The complaint, with the cut it is about, so the answer can keep the
    # words the complaint leaves alone.
    def self.revision(sentence, feedback)
      return {} unless feedback.key?(sentence)

      { feedback: feedback[sentence], previous: sentence.tokens.pluck("text") }
    end

    # No words at all would leave the sentence looking unsegmented, so an
    # empty answer counts as a failure even for a sentence with no Han.
    def self.verified(sentence, row)
      words = row&.dig("words")
      return if words.blank?

      words if sentence.partitioned_by?(words.pluck("text")) &&
        words.all? { |word| word["simplified"].length == word["text"].length }
    end
  end
end
