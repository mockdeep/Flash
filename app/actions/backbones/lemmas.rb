# frozen_string_literal: true

module Backbones
  # The base forms of a text's words, asked of Claude once per form as it
  # first appears and kept in a file, since every draft of a backbone reuses
  # most of the forms before it. A form the answer leaves out is asked again
  # next time.
  class Lemmas
    BATCH = 120

    # A form as written, what kind of word it is (word / name / numeral, or
    # unknown when unanswered), the base forms it is made of (a contraction
    # gives each part), and other headwords a list may hold it under.
    Word = Data.define(:form, :kind, :lemmas, :alternatives)

    class Word
      def word? = kind == "word"
      def name? = kind == "name"
      def unknown? = kind == "unknown"
    end

    SYSTEM = <<~TEXT
      You give the dictionary base form of Brazilian Portuguese words, as a
      learner's dictionary lists them. For each item you get a word form as
      written and the sentence it appears in. Answer with:
      - kind: "word"; "name" for a person's or place's name or other proper
        noun (Itaguaí, Bacamarte, Corão, Rio de Janeiro); "numeral" for a
        Roman numeral.
      - lemmas: the base form(s), lower case: verbs in the infinitive, nouns
        in the singular with no article, adjectives in the masculine
        singular, adverbs as they are. Split contractions into their parts
        (do → de, o; pelo → por, o; num → em, um; dali → de, ali; dele → de,
        ele) and verb + pronoun forms into the verb and the pronoun
        (disse-lhe → dizer, lhe; defendeu-a → defender, a; instalou-se →
        instalar, se). A superlative in -íssimo gives its adjective. A
        diminutive or augmentative gives its own form unless it is just a
        size. A hyphenated compound noun (pobre-diabo) stays whole. Names get
        their own form as the lemma.
      - alternatives: other headwords a dictionary might list the same word
        under, lower case: a feminine-only or plural-only form (grávida,
        juntos), the verb behind a participle used as an adjective (enganado
        → enganar), the feminine noun for a female person (viúva). Empty when
        there are none.
    TEXT

    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["words"],
      properties: {
        words: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "kind", "lemmas", "alternatives"],
            properties: {
              id: { type: "integer" },
              kind: { type: "string", enum: ["word", "name", "numeral"] },
              lemmas: { type: "array", items: { type: "string" } },
              alternatives: { type: "array", items: { type: "string" } },
            },
          },
        },
      },
    }.freeze

    QUESTION = {
      list: "words",
      model: Llm::SONNET,
      system: SYSTEM,
      schema: SCHEMA,
    }.freeze

    def initialize(path)
      @path = path
      @known = File.exist?(path) ? JSON.parse(File.read(path)) : {}
    end

    # A Word for each occurrence, a [form, sentence] pair, asking about the
    # forms not yet known with the first sentence each appears in.
    def for(occurrences)
      unknown = occurrences.uniq(&:first).reject { @known.key?(it.first) }
      unknown.each_slice(BATCH) { ask(it) }
      occurrences.map { |form, _| word(form) }
    end

    private

    def ask(occurrences)
      prompt =
        occurrences.each_with_index.map do |(form, sentence), id|
          { id:, form:, sentence: }
        end
      rows = Llm::AskEach.call(occurrences, prompt:, **QUESTION)
      occurrences.each_with_index do |(form, _), id|
        remember(form, rows[id]) if rows[id]
      end
      save
    end

    def remember(form, row)
      @known[form] = {
        "kind" => row["kind"],
        "lemmas" => row["lemmas"].map(&:downcase),
        "alternatives" => row["alternatives"].map(&:downcase),
      }
    end

    def save
      FileUtils.mkdir_p(File.dirname(@path))
      File.write(@path, JSON.pretty_generate(@known.sort.to_h))
    end

    def word(form)
      known = @known[form]
      unless known
        return Word.new(form:, kind: "unknown", lemmas: [], alternatives: [])
      end

      Word.new(
        form:,
        kind: known["kind"],
        lemmas: known["lemmas"],
        alternatives: known["alternatives"],
      )
    end
  end
end
