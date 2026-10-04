# frozen_string_literal: true

module Snippets
  # Segments a batch of sentences into words. The model's answer is checked
  # mechanically: the words must rejoin to the sentence's Han characters. A
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
    TEXT
    SYSTEM = [INSTRUCTIONS, Policy::SEGMENTATION].join("\n").freeze
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
              words: { type: "array", items: { type: "string" } },
            },
          },
        },
      },
    }.freeze
    ASK = {
      list: "sentences", model: Llm::SONNET, system: SYSTEM, schema: SCHEMA
    }.freeze

    def self.call(sentences)
      answers = ask(sentences)

      sentences.each_with_index do |sentence, id|
        tokens = words(sentence, answers[id]).map { |word| { "text" => word } }
        sentence.update!(tokens:)
      end
    end

    def self.words(sentence, row)
      verified(sentence, row) ||
        verified(sentence, ask([sentence]).values.first) ||
        sentence.body.chars
    end

    def self.ask(sentences)
      prompt =
        sentences.each_with_index.map do |sentence, id|
          { id:, sentence: sentence.body }
        end

      Llm::AskEach.call(sentences, prompt:, **ASK)
    end

    # No words at all would leave the sentence looking unsegmented, so an
    # empty answer counts as a failure even for a sentence with no Han.
    def self.verified(sentence, row)
      words = row&.dig("words")
      words if words.present? && sentence.partitioned_by?(words)
    end
  end
end
