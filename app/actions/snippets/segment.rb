# frozen_string_literal: true

module Snippets
  # Segments a batch of sentences into words, each with its simplified form
  # (the headword it studies under), kept on the token only where it differs.
  # The model sees the sentence, so it can pick by meaning where a
  # traditional character simplifies more than one way. The answer is
  # checked mechanically: the words must rejoin to the sentence's Han
  # characters, and each simplified form must be as long as its word. A
  # sentence that fails is asked again on its own, and one that fails twice
  # falls back to one token per character.
  module Segment
    INSTRUCTIONS = <<~TEXT
      You segment Chinese sentences into words for a vocabulary
      builder. For each sentence, return its words in order. Keep names,
      idioms and set phrases whole. Each word should be one a learner could
      look up in a dictionary, so split grammatical particles off the word
      they follow: aspect particles (了, 着/著, 过/過) and structural particles
      (的, 地, 得) are words of their own ("花了" is "花", "了"; "看着" is "看", "着"),
      unless the combination is itself a dictionary word ("为了", "除了",
      "觉得", "目的"). Every character of the sentence must appear in
      exactly one word, unchanged: do not drop, add, convert or correct
      characters. Punctuation is never part of a word: quotation marks,
      title marks (《》), brackets and the rest are tokens of their own or
      left out ("《新黑客辞典》" is "《", "新黑客辞典", "》").

      Return each word as `text`, exactly as written, and `simplified`, the
      same word in simplified characters, character for character; it is
      identical to `text` for a word already in simplified characters or
      with no Chinese in it. Where a traditional character simplifies more
      than one way, choose by its meaning here: 著 as an aspect particle is
      着, but stays 著 for "to write"; 乾 is 干 for "dry", but stays 乾 in
      乾坤.

      A sentence may carry `feedback`: what a reviewer found wrong with an
      earlier segmentation of it. Segment it again so that every complaint
      is fixed.
    TEXT
    SYSTEM = [INSTRUCTIONS, Policy::SEGMENTATION].join("\n").freeze
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
    ASK = {
      list: "sentences", model: Llm::SONNET, system: SYSTEM, schema: SCHEMA
    }.freeze

    # `feedback` maps a sentence to what was wrong with its last
    # segmentation, for one sent back to be segmented again.
    def self.call(sentences, feedback: {})
      answers = ask(sentences, feedback)

      sentences.each_with_index do |sentence, id|
        sentence.update!(tokens: tokens(sentence, answers[id], feedback))
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

      { "text" => text, "simplified" => simplified }
    end

    def self.ask(sentences, feedback)
      prompt =
        sentences.each_with_index.map do |sentence, id|
          { id:, sentence: sentence.body, feedback: feedback[sentence] }.compact
        end

      Llm::AskEach.call(sentences, prompt:, **ASK)
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
