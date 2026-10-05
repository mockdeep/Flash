# frozen_string_literal: true

module Snippets
  # The judging tier: nothing enters the compendium on one model's say-so.
  # Returns the proposals it accepts; a rejected proposal's occurrence keeps
  # the judge's reason.
  module Judge
    INSTRUCTIONS = <<~TEXT
      You review proposed new senses for a Chinese vocabulary
      compendium. Another model proposed each one, claiming that none of
      the listed existing senses covers the word as it is used in the
      sentence. The input has three lists. `sentences` gives each sentence
      once. `words` gives each distinct word once: the simplified
      `headword` it studies under and the senses the compendium already
      holds (`senses`).
      `occurrences` are the proposals: each is one occurrence of a `word`
      (listed under `wid`) in a sentence (`sid`), shown between 【 and 】
      among its neighbours in `marked`, with the proposed headword, reading
      and gloss. Nothing enters the compendium unless you accept it, and a
      wrong entry reaches every learner, so reject whenever you have a
      concrete objection:

      - a listed existing sense already covers this occurrence (say which);
        for a function word, only one that names the same role does
      - the reading is wrong for this occurrence
      - the gloss is not what the word means in this sentence
      - the headword is not the right simplified form of the word for this
        meaning (著 as a particle belongs under 着)
      - another occurrence proposes the same word in the same meaning under a
        different reading or gloss: accept the better wording and reject the
        other
      - the "word" is not a word, but a fragment of bad segmentation, or a
        whole the segmentation rules below would split
      - the gloss holds hanzi, pinyin, cross-references, several unrelated
        meanings, or explanation beyond a short gloss
      - the reading or gloss breaks the reading and gloss rules below

      Accept when the reading and gloss are right for the sentence and the
      sense is distinct from the listed ones. Give a verdict for every
      occurrence, and a one-sentence reason only when you reject: the reason
      goes to the next proposer, or to the person who reviews the text.
    TEXT
    SYSTEM = [
      INSTRUCTIONS,
      Policy::FUNCTION_WORDS,
      Policy::READING,
      Policy::SEGMENTATION,
    ].join("\n").freeze
    UNREASONED = "rejected without a reason"
    SCHEMA = {
      type: "object",
      additionalProperties: false,
      required: ["verdicts"],
      properties: {
        verdicts: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "accept"],
            properties: {
              id: { type: "integer" },
              accept: { type: "boolean" },
              reason: { type: "string" },
            },
          },
        },
      },
    }.freeze
    ASK = { list: "verdicts", system: SYSTEM, schema: SCHEMA }.freeze
    UNJUDGED = {
      "accept" => false,
      "reason" => "no verdict was returned",
    }.freeze

    def self.call(proposals, model:)
      occurrences = proposals.map(&:occurrence)
      prompt = Briefing.call(occurrences, proposed: proposals.map(&:proposed))
      verdicts = Llm::AskEach.call(proposals, prompt:, model:, **ASK)

      proposals.each_with_index.filter_map do |proposal, id|
        judged(proposal, verdicts.fetch(id, UNJUDGED))
      end
    end

    def self.judged(proposal, verdict)
      occurrence = proposal.occurrence
      occurrence.rejection =
        verdict["accept"] ? nil : verdict["reason"].presence || UNREASONED
      proposal unless occurrence.rejection
    end
  end
end
