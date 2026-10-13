# frozen_string_literal: true

module Snippets
  # Segments a batch of sentences into words, each with the form it studies
  # under (a simplified form, or a lower-cased one), kept on the token as
  # `headword` only where it differs. The model sees the sentence, so it can
  # pick by meaning where a traditional character simplifies more than one
  # way. The answer is checked mechanically: the words must rejoin to the
  # sentence's word characters, and each form must fit its word as the
  # language says. A sentence that fails is asked again on its own, and one
  # that fails twice falls back to the language's pieces (characters for
  # Mandarin).
  module Segment
    WORD = {
      type: "object",
      additionalProperties: false,
      properties: { text: { type: "string" } },
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
              words: { type: "array" },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "sentences", model: Llm::SONNET }.freeze

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
      language = sentence.language
      words =
        verified(sentence, row) ||
        verified(sentence, ask([sentence], feedback).values.first) ||
        sentence.body.scan(language.piece).map { |piece| { "text" => piece } }

      words.map { |word| token(word, language) }
    end

    # The headword is kept only where it differs from the text.
    def self.token(word, language)
      text, headword, skip = word.values_at("text", language.form, "skip")
      headword = nil if headword == text

      { "text" => text, "headword" => headword, "skip" => skip }.compact
    end

    def self.ask(sentences, feedback)
      prompt =
        sentences.each_with_index.map do |sentence, id|
          { id:, sentence: sentence.body, **revision(sentence, feedback) }
        end

      language = sentences.first.language
      system = language.prompts.segment
      schema = schema(language)
      Llm::AskEach.call(sentences, prompt:, system:, schema:, **ASK)
    end

    # Each word comes with the form it studies under, named as the language
    # names it.
    def self.schema(language)
      form = language.form
      properties = { form.to_sym => { type: "string" } }
      if language.skips.any?
        properties[:skip] = { type: "string", enum: language.skips }
      end
      word = WORD.deep_merge(required: ["text", form], properties:)
      words = { words: { items: word } }

      SCHEMA.deep_merge(
        properties: { sentences: { items: { properties: words } } },
      )
    end

    # The complaint, with the cut it is about, so the answer can keep the
    # words the complaint leaves alone.
    def self.revision(sentence, feedback)
      return {} unless feedback.key?(sentence)

      { feedback: feedback[sentence], previous: sentence.tokens.pluck("text") }
    end

    # No words at all would leave the sentence looking unsegmented, so an
    # empty answer counts as a failure even for a sentence with no words.
    def self.verified(sentence, row)
      words = row&.dig("words")
      return if words.blank?

      language = sentence.language
      words if sentence.partitioned_by?(words.pluck("text")) &&
        words.all? do |word|
          language.form_fits.call(word["text"], word[language.form])
        end
    end
  end
end
