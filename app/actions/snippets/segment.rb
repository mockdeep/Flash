# frozen_string_literal: true

module Snippets
  # Segments a batch of sentences into words, each with the form it studies
  # under (a simplified form, or a lower-cased one), kept on the token as
  # `headword` only where it differs, and in Mandarin its traditional form,
  # kept as `traditional` the same way. The model sees the sentence, so it
  # can pick by meaning where a character converts more than one way. The
  # answer is checked mechanically: the words must rejoin to the sentence's
  # word characters, and each form must fit its word as the language says.
  # A sentence that fails is asked again on its own, and one that fails
  # twice falls back to the language's pieces (characters for Mandarin). A
  # sentence with no letters or digits (an emoticon) goes straight to pieces,
  # since the model has nothing to cut.
  module Segment
    TEXT = /[\p{L}\p{N}]/
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
      worded, wordless = sentences.partition { it.body.match?(TEXT) }
      wordless.each { it.update!(tokens: pieces(it)) }
      return if worded.empty?

      answers = ask(worded, feedback)

      worded.each_with_index do |sentence, id|
        tokens = tokens(sentence, answers[id], feedback)
        tokens = Recut.call(sentence, tokens) if feedback.key?(sentence)
        sentence.update!(tokens:)
      end
    end

    def self.tokens(sentence, row, feedback)
      words =
        verified(sentence, row) ||
        verified(sentence, ask([sentence], feedback).values.first) ||
        pieces(sentence)

      words.map { |word| token(word, sentence.language) }
    end

    def self.pieces(sentence)
      sentence.body.scan(sentence.language.piece).map { { "text" => it } }
    end

    # The headword and traditional form are kept only where they differ
    # from the text.
    def self.token(word, language)
      text, headword, traditional, skip =
        word.values_at("text", language.form, "traditional", "skip")
      forms =
        { "headword" => headword, "traditional" => traditional }
          .reject { |_, form| form == text }

      { "text" => text, **forms, "skip" => skip }.compact
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
      forms = forms(language)
      properties = forms.to_h { [it.to_sym, { type: "string" }] }
      if language.skips.any?
        properties[:skip] = { type: "string", enum: language.skips }
      end
      word = WORD.deep_merge(required: ["text", *forms], properties:)
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
          forms(language).all? do |form|
            language.form_fits.call(word["text"], word[form].to_s)
          end
        end
    end

    def self.forms(language)
      [language.form, ("traditional" if language.traditional)].compact
    end
  end
end
