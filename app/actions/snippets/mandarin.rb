# frozen_string_literal: true

module Snippets
  # The prompts for processing Mandarin snippets.
  module Mandarin
    SEGMENT_INSTRUCTIONS = <<~TEXT
      You segment Chinese sentences into words for a vocabulary
      builder. For each sentence, return its words in order. Keep names and
      idioms whole. Each word should be one a learner could look up, so
      split grammatical particles off the word they follow: aspect
      particles (了, 着/著, 过/過) and structural particles (的, 地, 得) are
      words of their own ("花了" is "花", "了"; "看着" is "看", "着"), unless
      the combination has a meaning of its own ("为了", "除了", "觉得",
      "目的"). Every character of the sentence must appear in
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

      Return `traditional` too: the same word in traditional characters as
      Taiwan writes it, character for character; it is identical to `text`
      for a word already in traditional characters or with no Chinese in
      it. Where a simplified character stands for more than one traditional
      one, choose by its meaning here: 发 is 髮 for "hair", but 發 for "to
      send"; 干 is 乾 for "dry", but 幹 for "to do".

      A sentence may carry `feedback`: what a reviewer found wrong with an
      earlier segmentation of it, and `previous`: that segmentation's words.
      Segment it again so that every complaint is fixed, and keep every
      other word of `previous` exactly as it was: change only the words a
      complaint names.
    TEXT

    PROPOSE_INSTRUCTIONS = <<~TEXT
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
        fits when its gloss could stand in for the word in an English
        rendering of this sentence. 人体健康 is "human health", so 健康
        "healthy" does not fit there, and a new sense "health" is needed.
      - "new": no listed sense covers this occurrence. Return a reading and a
        gloss. The reading is pinyin with tone marks and the syllables
        joined ("niànshū"), capitalised for names; when a listed sense is
        pronounced the same way, copy its reading exactly. The gloss is a
        short English gloss of this one meaning. No hanzi, no pinyin, no
        cross-references. Gloss a proper noun by the English name of what it
        names in this text (新 in 新马 is "Singapore"), and a function word
        by its function ("possessive particle"). When
        two occurrences are the same word in the same new meaning, give them
        the identical reading and gloss.
      - "missegmented": the token breaks the segmentation rules below: two
        words joined (a verb with its aspect particle, "花了"), a piece cut
        from a longer word, or a whole the rules split. Say in note how it
        should have been split or joined. The sentence is segmented again.

      An occurrence may carry `rejection`: a reviewer's reason for turning
      down an earlier proposal for it. Take it into account.

      A sentence may carry `resegmented`: the complaint it was already
      segmented again over, which settles how it is cut. Never call a token
      missegmented to undo what the complaint asked for; do so only when the
      new segmentation breaks the rules some other way.

      Every token gets a sense: there is no skipping, even for a single
      numeral, a typo or a stray character. Return only the fields a
      decision uses: sense_id for "existing"; reading and gloss for "new";
      note for "missegmented".
    TEXT

    JUDGE_INSTRUCTIONS = <<~TEXT
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

      - a listed existing sense already covers this occurrence (say which):
        one covers it only if its gloss could stand in for the word in an
        English rendering of the sentence, so 健康 "healthy" does not cover
        人体健康 "human health"; for a function word, only one that names
        the same role does
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

      A sentence may carry `resegmented`: the complaint it was already
      segmented again over. A word the complaint asked for is not bad
      segmentation on that ground alone.

      Accept when the reading and gloss are right for the sentence and the
      sense is distinct from the listed ones. Give a verdict for every
      occurrence, and a one-sentence reason only when you reject: the reason
      goes to the next proposer, or to the person who reviews the text.
    TEXT

    CATEGORIZE = <<~TEXT
      You file Chinese vocabulary by part of speech. Each item gives a
      headword, its reading and one English gloss; choose the category that
      fits the word in that meaning. Use "proper noun" for names of people,
      places and works, "idiom" for chengyu and set sayings, "phrase" for a
      multi-word expression that is none of the others, and "other" only
      when nothing else fits.
    TEXT

    CATEGORIES = [
      "noun",
      "verb",
      "adjective",
      "adverb",
      "pronoun",
      "conjunction",
      "preposition",
      "particle",
      "measure word",
      "numeral",
      "proper noun",
      "idiom",
      "phrase",
      "other",
    ].freeze

    PROMPTS = Prompts.new(
      segment: [SEGMENT_INSTRUCTIONS, Policy::SEGMENTATION].join("\n").freeze,
      propose: [
        PROPOSE_INSTRUCTIONS,
        Policy::FUNCTION_WORDS,
        Policy::READING,
        Policy::SEGMENTATION,
      ].join("\n").freeze,
      judge: [
        JUDGE_INSTRUCTIONS,
        Policy::FUNCTION_WORDS,
        Policy::READING,
        Policy::SEGMENTATION,
      ].join("\n").freeze,
      categorize: CATEGORIZE,
    )
  end
end
