# frozen_string_literal: true

# The base forms of a text's words, asked of Claude once per form as it
# first appears and kept in a file per language, since texts reuse most of
# the forms before them: every draft of a backbone, and every snippet the
# segmenter looks for curriculum phrases in. A form the answer leaves out
# is asked again next time.
class Lemmas
  BATCH = 120
  DIR = Rails.root.join("tmp/lemmas")
  # The languages it can answer for.
  LANGUAGES = Prompts::BY_LANGUAGE.keys.freeze

  # A form as written, what kind of word it is (word / name / numeral /
  # interjection, or unknown when unanswered), the base forms it is made of
  # (a contraction gives each part), and other headwords a list may hold it
  # under.
  Word = Data.define(:form, :kind, :lemmas, :alternatives)

  class Word
    def word? = kind == "word"
    def name? = kind == "name"
    def unknown? = kind == "unknown"
  end

  KINDS = ["word", "name", "numeral", "interjection"].freeze

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
            kind: { type: "string", enum: KINDS },
            lemmas: { type: "array", items: { type: "string" } },
            alternatives: { type: "array", items: { type: "string" } },
          },
        },
      },
    },
  }.freeze

  QUESTION = { list: "words", model: Llm::SONNET, schema: SCHEMA }.freeze

  def self.in(language) = new(DIR.join("#{language}.json"), language:)

  def initialize(path, language:)
    @path = path
    @system = Prompts::BY_LANGUAGE[language]
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
    question = { prompt:, system: @system, **QUESTION }
    rows = Llm::AskEach.call(occurrences, **question)
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
    known = @known[form] || { "kind" => "unknown" }

    Word.new(
      form:,
      kind: known["kind"],
      lemmas: known.fetch("lemmas", []),
      alternatives: known.fetch("alternatives", []),
    )
  end
end
