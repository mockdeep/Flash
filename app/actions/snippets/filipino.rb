# frozen_string_literal: true

module Snippets
  # The prompts for processing Filipino snippets. A word studies under the
  # form it has in the text, accents and affixes kept (an abbreviation
  # written out), with no reading, and its gloss renders that form.
  module Filipino
    SEGMENTATION = <<~TEXT
      Segmentation rules. A word is what a learner would look up as one
      card, in the form the text gives it.
      1. Keep every word in its form here, affixes, infixes and repeated
         syllables included: never reduce a verb or noun to its root
         ("kinakain" stays "kinakain", "pagkain" stays "pagkain").
      2. Keep every accent mark the text writes (susô, taón, ibinukás), and
         add none it leaves out.
      3. A word with the linker joined to it is one word (isang, ideang,
         iyong), as is a word with a shortened "at" or "ay" joined by an
         apostrophe (kaya't, siya'y). A "ng" written apart is a word of its
         own: never join it to the word before.
      4. A hyphenated word is one word: a repeated root (tuwang-tuwa,
         kaisa-isang, kaiba-iba), a prefix before a vowel (nag-iisip,
         mag-alaga) or a compound (bahay-kubo).
      5. A fixed phrase is one word when its meaning cannot be worked out
         from its words (para sa "for", dahil sa "because of", kung saan
         "where"). Split a combination whose words, each glossed on its
         own, already say what it means. When unsure, keep whole what a
         standard dictionary lists as one entry.
      6. A marker or particle is a word of its own (ang, ng, sa, si, ni,
         kay, mga, ay, na, pa, ba, din, rin, daw, raw, lang, nga, naman,
         po).
      7. A name of several words is one word (Ben Zayb, Ilog Pasig), but a
         title before a name is a word of its own (don, padre, kapitan,
         tandang, G., Sta.): "Sta. Cruz" is "Sta." and "Cruz".
      8. Digits are one token; punctuation is never part of a word, except
         the full stop of an abbreviation (G., Gng., Dr.) and the apostrophe
         of a shortened "at" or "ay" (kaya't).

      Headword rules. A word studies under its headword: the word as
      written, accents kept, in lower case. Only these keep their capital,
      linker and all: a name (Maynila, Koliseo), a people or one of its
      members (Indio, Indiong, Hudyo, Amerikano), a language (Ingles,
      Kastila), a month, day or holiday (Pebrero, Lunes, Pasko), a word
      made from a place's name (Kabitenyo, Pilipino, taga-Timog) and a
      Roman numeral (Leon XIII). Every other word is lower case, even where
      the text capitalises it to start a sentence, out of respect or as a
      title: "hindi", "hari", "heneral", "kataas-taasan", "padre". An
      abbreviation's headword is the word it stands for here, written out
      in lower case: G. is "ginoo", Gng. is "ginang", Bb. is "binibini",
      Dr. is "doktor" or "doktora", Sto. is "santo", Sta. is "santa", Mr.
      is "mister".
    TEXT

    GLOSSES = <<~TEXT
      Gloss rules:
      - Gloss what is written, as it is used in this sentence, even where the
        text has a typo. Never gloss the word the author probably meant.
      - A gloss is what a reader needs in place of this form: usually one to
        four English words that carry what the form adds. A verb's gloss
        carries its aspect and focus: kumain "ate", kumakain "is eating",
        kakain "will eat", kinain "was eaten", kinakain "is being eaten",
        ipinagluto "cooked for". A noun or adjective made from a root
        carries what the affix adds (pagkain "food", kainan "eating place",
        maganda "beautiful").
      - Gloss a noun in the singular (mga marks the plural), a verb with
        "is" or "was" unless its form marks a plural subject (nagsialis "all
        left"), and a pronoun of either gender with both (siya "he, she",
        niya "his, her").
      - Give the subject only when the form fixes it and English would lose
        it: kami "we (not you)", tayo "we (including you)".
      - Gloss a word with a joined linker or shortened "at" or "ay" by the
        whole (isang "a, one", kaya't "and so", siya'y "he is, she is").
      - Gloss a marker or particle by the English word doing the same job
        here (sa "to", "at" or "in"; ng "of"; kay "to (a person)"; din
        "also"; lang "only"; pa "still" or "yet"; na "already"). Where
        English has no word for the job, give a short label in brackets:
        ang "(topic marker)", si "(marks a name)", mga "(plural)", ba
        "(question particle)", po "(polite)", ay "(links subject and
        predicate)", na "(linker)" where it joins a word to what describes
        it.
      - Gloss a word with an accent by the meaning that accent gives it:
        bukás "open" but búkas "tomorrow".
      - A name is glossed by its usual English name (Maynila "Manila"), with
        no note on what it is.
      - Leave out the root, grammar labels beyond those above, explanations
        of use and any Filipino.
    TEXT

    SEGMENT_INSTRUCTIONS = <<~TEXT
      You segment Filipino sentences into words for a vocabulary builder.
      For each sentence, return its words in order. Every word of the
      sentence must appear in exactly one item, unchanged: do not drop, add,
      correct or re-spell anything, accent marks included. Punctuation
      (quotation marks, dashes, brackets and the rest) is never part of a
      word: it is a token of its own or left out.

      Return each word as `text`, exactly as written, and `headword`, the
      form it is studied under by the headword rules below: it differs
      from the text in letter case alone, except for an abbreviation.

      Some words get no card; mark each, kept whole as one word:
      - `skip: "name"`: a name English leaves as it is: a person or
        character in any language ("Ben Zayb", "Simoun", "Camora"), and a
        place, newspaper or anything else English calls by
        the same name ("Pateros", "Pasig").
      - `skip: "foreign"`: a passage, title or other name left in another
        language, such as Spanish or Latin the text quotes as it is
        ("Noli me tangere", "¡Qué barbaridad!").
      A title before a name gets a card: "Don Custodio" is "don" and
      "Custodio" (`skip: "name"`).
      A name English calls something else gets a card like any other word
      ("Maynila" Manila, "Espanya" Spain, "Koliseo" Colosseum), and so does
      a Spanish or English word the sentence uses as Filipino ("proyekto",
      "senyor", "padre de pamilya").

      A sentence may carry `feedback`: what a reviewer found wrong with an
      earlier segmentation of it, and `previous`: that segmentation's words.
      Segment it again so that every complaint is fixed, and keep every
      other word of `previous` exactly as it was: change only the words a
      complaint names.
    TEXT

    PROPOSE_INSTRUCTIONS = <<~TEXT
      You build vocabulary cards from Filipino texts. The input has three
      lists. `sentences` gives each sentence once. `words` gives each
      distinct word once: the `headword` it studies under and the senses our
      compendium already holds for it (`senses`). `occurrences` are the
      questions: each is one occurrence of a `word` (listed under `wid`) in
      a sentence (`sid`), and `marked` shows it between 【 and 】 among its
      neighbours. A word may have several occurrences, even twice in one
      sentence; decide each on its own, because the same word can be used
      in different senses. Answer every occurrence, deciding how the marked
      word is used:

      - "existing": one of the listed senses covers this occurrence. Return
        its id as sense_id. Prefer this whenever a listed sense fits: a sense
        fits when its gloss could stand in for the word in an English
        rendering of this sentence. In "Nasa bahay na siya" the na is
        "already", so a sense "(linker)" does not fit.
      - "new": no listed sense covers this occurrence. Return a gloss under
        the gloss rules below, and no reading or article. When two
        occurrences are the same word in the same new meaning, give them
        the identical gloss.
      - "missegmented": the token breaks the segmentation rules below: two
        words joined, a piece cut from a longer word or fixed phrase, or a
        whole the rules split. Say in note how it should have been split or
        joined. The sentence is segmented again.

      An occurrence may carry `rejection`: a reviewer's reason for turning
      down an earlier proposal for it. Take it into account.

      A sentence may carry `resegmented`: the complaint it was already
      segmented again over, which settles how it is cut. Never call a token
      missegmented to undo what the complaint asked for; do so only when the
      new segmentation breaks the rules some other way.

      Every token gets a sense: there is no skipping, even for a lone
      marker, a typo or a stray letter. Return only the fields a decision
      uses: sense_id for "existing"; gloss for "new"; note for
      "missegmented".
    TEXT

    JUDGE_INSTRUCTIONS = <<~TEXT
      You review proposed new senses for a Filipino vocabulary compendium.
      Another model proposed each one, claiming that none of the listed
      existing senses covers the word as it is used in the sentence. The
      input has three lists. `sentences` gives each sentence once. `words`
      gives each distinct word once: the `headword` it studies under and the
      senses the compendium already holds (`senses`). `occurrences` are the
      proposals: each is one occurrence of a `word` (listed under `wid`) in
      a sentence (`sid`), shown between 【 and 】 among its neighbours in
      `marked`, with the proposed headword and gloss. Nothing enters the
      compendium unless you accept it, and a wrong entry reaches every
      learner, so reject whenever you have a concrete objection:

      - a listed existing sense already covers this occurrence (say which):
        one covers it only if its gloss could stand in for the word in an
        English rendering of the sentence
      - the gloss is not what this form means in this sentence, or loses
        what the form adds (a completed action glossed as ongoing, an
        object-focus verb glossed as actor-focus, a plural as singular)
      - the headword breaks the headword rules below
      - another occurrence proposes the same word in the same meaning under a
        different gloss: accept the better wording and reject the other
      - the "word" is not a word, but a fragment of bad segmentation, or a
        whole the segmentation rules below would split
      - the gloss holds Filipino, the root, grammar labels beyond the ones
        the gloss rules allow, several unrelated meanings, or explanation
        beyond a short gloss
      - the gloss breaks the gloss rules below

      A sentence may carry `resegmented`: the complaint it was already
      segmented again over. A word the complaint asked for is not bad
      segmentation on that ground alone.

      Accept when the gloss is right for the sentence and the sense is
      distinct from the listed ones. Give a verdict for every occurrence,
      and a one-sentence reason only when you reject: the reason goes to the
      next proposer, or to the person who reviews the text.
    TEXT

    CATEGORIZE = <<~TEXT
      You file Filipino vocabulary by part of speech. Each item gives a
      headword, in the form a text used it, and one English gloss; choose
      the category that fits the word in that meaning. Use "marker" for a
      word that marks a noun's role (ang, ng, sa, si, ni, kay, mga),
      "particle" for a small word that adds a shade of meaning (ba, din,
      daw, lang, nga, naman, pa, po), "linker" for na or a word whose linker
      is the point of it, "verb" for any verb form, "proper noun" for names
      of people, places and works, "phrase" for a multi-word expression that
      is none of the others, and "other" only when nothing else fits.
    TEXT

    CATEGORIES = [
      "noun",
      "verb",
      "adjective",
      "adverb",
      "pronoun",
      "marker",
      "particle",
      "linker",
      "preposition",
      "conjunction",
      "numeral",
      "interjection",
      "proper noun",
      "phrase",
      "other",
    ].freeze

    PROMPTS = Prompts.new(
      segment: [SEGMENT_INSTRUCTIONS, SEGMENTATION].join("\n").freeze,
      propose: [PROPOSE_INSTRUCTIONS, GLOSSES, SEGMENTATION].join("\n").freeze,
      judge: [JUDGE_INSTRUCTIONS, GLOSSES, SEGMENTATION].join("\n").freeze,
      categorize: CATEGORIZE,
    )
  end
end
