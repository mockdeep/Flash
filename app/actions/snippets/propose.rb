# frozen_string_literal: true

module Snippets
  # The proposing tier: for each occurrence, pick an existing sense, propose
  # a new one, or call the token missegmented. A decision that breaks the
  # rules is turned into a rejection, and the occurrence is left unresolved.
  module Propose
    INSTRUCTIONS = <<~TEXT
      You build vocabulary cards from Chinese texts. The input has three
      lists. `sentences` gives each sentence once. `words` gives each
      distinct word once: the simplified `headword` it studies under and the
      senses our compendium already holds for it (`senses`). `occurrences` are the
      questions: each is one occurrence of a `word` (listed under `wid`) in
      a sentence (`sid`), and `marked` shows it between 【 and 】 among its
      neighbours. A word may have several occurrences, even twice in one
      sentence; decide each on its own, because the same word can be used
      in different senses. Answer every occurrence, deciding how the marked
      word is used:

      - "existing": one of the listed senses covers this occurrence. Return
        its id as sense_id. Prefer this whenever a listed sense fits: a sense
        fits when a learner who knows it would understand the word here.
      - "new": no listed sense covers this occurrence. Return a reading and a
        gloss. The reading is pinyin with tone marks and the syllables
        joined ("niànshū"), capitalised for names; when a listed sense is
        pronounced the same way, copy its reading exactly. The gloss is a
        short English gloss of this one meaning. No hanzi, no pinyin, no
        cross-references. Gloss a proper noun by what it names in this text,
        and a function word by its function ("possessive particle"). When
        two occurrences are the same word in the same new meaning, give them
        the identical reading and gloss.
      - "missegmented": the token breaks the segmentation rules below: two
        words joined (a verb with its aspect particle, "花了"), a piece cut
        from a longer word, or a whole the rules split. Say in note how it
        should have been split or joined.

      Every token gets a sense: there is no skipping, even for a single
      numeral, a typo or a stray character. Return only the fields a
      decision uses: sense_id for "existing"; reading and gloss for "new";
      note for "missegmented".
    TEXT
    SYSTEM = [
      INSTRUCTIONS,
      Policy::FUNCTION_WORDS,
      Policy::READING,
      Policy::SEGMENTATION,
    ].join("\n").freeze
    DECISIONS = ["existing", "new", "missegmented"].freeze
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["decisions"],
      properties: {
        decisions: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "decision"],
            properties: {
              id: { type: "integer" },
              decision: { type: "string", enum: DECISIONS },
              sense_id: { type: "integer" },
              reading: { type: "string" },
              gloss: { type: "string" },
              note: { type: "string" },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "decisions", system: SYSTEM, schema: SCHEMA }.freeze

    def self.call(occurrences, model:)
      prompt = Briefing.call(occurrences)
      rows = Llm::AskEach.call(occurrences, prompt:, model:, **ASK)

      occurrences.each_with_index.filter_map do |occurrence, id|
        proposal(occurrence, rows[id])
      end
    end

    def self.proposal(occurrence, row)
      proposal = Proposal.from(occurrence, row || {})
      occurrence.rejection =
        row ? proposal.problem : "no decision was returned"
      proposal unless occurrence.rejection
    end
  end
end
