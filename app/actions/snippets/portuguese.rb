# frozen_string_literal: true

module Snippets
  # The prompts for processing Portuguese snippets. A word studies under the
  # form it has in the text (an abbreviation written out), with no reading,
  # and its gloss renders that form.
  module Portuguese
    SEGMENTATION = <<~TEXT
      Segmentation rules. A word is what a learner would look up as one
      card, in the form the text gives it.
      1. Keep every word in its form here: never reduce a verb to its
         infinitive or a noun or adjective to its masculine singular
         ("falávamos" stays "falávamos", "bonitas" stays "bonitas").
      2. A preposition joined to an article or pronoun is one word (do, na,
         pelo, dele, num, àquela).
      3. A verb with pronouns joined by hyphens is one word (diga-me,
         levantou-se, dar-lhe-ia), as is any hyphenated compound
         (guarda-chuva, segunda-feira).
      4. A fixed phrase is one word when its meaning cannot be worked out
         from its words (de repente "suddenly", por causa de "because of", à
         toa "aimlessly", de novo "again"). Split a combination whose words,
         each glossed on its own, already say what it means (a casa velha →
         a, casa, velha). When unsure, keep whole what a standard dictionary
         lists as one entry.
      5. A name of several words is one word (São Paulo, Rio de Janeiro),
         but a title before a name is a word of its own, studied with its
         capital (Padre, Capitão, and abbreviations such as D., Sr., Sra.
         and Dr., which are studied written out).
      6. Digits are one token; punctuation is never part of a word, except
         the full stop of an abbreviation (Sr., D., Dr.).
    TEXT

    GLOSSES = <<~TEXT
      Gloss rules:
      - Gloss what is written, as it is used in this sentence, even where the
        text has a typo. Never gloss the word the author probably meant.
      - A gloss is what a reader needs in place of this form: usually one to
        four English words that carry what the form adds, such as tense or
        number ("houses", "would say", "had arrived"). Give the subject only
        when the form fixes it and English would lose it: falávamos is "we
        were speaking", but falava is "was speaking", since it serves
        several persons. Leave out gender unless it changes the meaning.
      - Gloss a contraction by the English it stands for (do "of the", nela
        "in her") and a verb with joined pronouns as a whole (diga-me "tell
        me").
      - Gloss a function word by the English word doing the same job here:
        que may be "that", "which" or "than"; se may be "if" or "oneself".
      - A name is glossed by its usual English name (Lisboa "Lisbon"), with
        no note on what it is.
      - Leave out the dictionary form, grammar labels, explanations of use
        and any Portuguese.
    TEXT

    ARTICLES = <<~TEXT
      Article rules: a noun is studied with its definite article, so a
      learner sees its gender.
      - Give a noun `article`: o, a, os or as, whichever fits this form's
        gender and number (casa "a", casas "as", lápis "o" or "os" as the
        sentence uses it). A word used as a noun here takes one too (o
        pobre). Where the gender follows the person meant (estudante,
        artista), take it from the sentence.
      - Give a name the article Portuguese uses with it (o Brasil, a França,
        o Natal), and none when it takes none (Lisboa, Deus, março). A title
        before a name (D., Sr., Dr.) takes none.
      - Give no article to any other word, nor to a phrase that is not a
        noun as a whole (fora de casa, no outro dia). A phrase that is one
        takes one (a missa do galo).
      - The gloss leaves out "the": the article carries it (a casa "house").
    TEXT

    SEGMENT_INSTRUCTIONS = <<~TEXT
      You segment Portuguese sentences into words for a vocabulary builder.
      For each sentence, return its words in order. Every word of the
      sentence must appear in exactly one item, unchanged: do not drop, add,
      correct or re-spell anything. Punctuation (quotation marks, dashes,
      brackets and the rest) is never part of a word: it is a token of its
      own or left out.

      Return each word as `text`, exactly as written, and `headword`, the
      form it is studied under: the same word in lower case, unless it is a
      name, a title before one (D., Sr.) or a Roman numeral (século XIX),
      which keeps its capitals. A word
      capitalised only because it starts a sentence is lower-cased ("Ela" →
      "ela"). An abbreviation's headword is the word it stands for here,
      written out with its capital: D. is "Dona" before a woman's name and
      "Dom" before a man's, Sr. is "Senhor", Dr. is "Doutor" or "Doutora".
      Otherwise the headword differs from the text in letter case alone.

      Some words get no card; mark each, kept whole as one word:
      - `skip: "name"`: a name English leaves as it is: a person or
        character in any language ("Friedrich Nietzsche", "Machado de
        Assis", "Brás Cubas"), and a place, newspaper or anything else
        English calls by the same name ("Mangaratiba", "Rio de Janeiro",
        "Jornal do Comércio").
      - `skip: "foreign"`: a title or other name left in another language
        ("Gone with the Wind", "Notre-Dame de Paris").
      A title before a name gets a card: "D. Inácia" is "D." and "Inácia"
      (`skip: "name"`).
      A name English calls something else is a word like any other
      ("Alemanha" Germany, "Lisboa" Lisbon, "O Senhor dos Anéis" The Lord of
      the Rings), and so is a foreign word the sentence uses as Portuguese
      ("o show", "um blog").

      A sentence may carry `feedback`: what a reviewer found wrong with an
      earlier segmentation of it, and `previous`: that segmentation's words.
      Segment it again so that every complaint is fixed, and keep every
      other word of `previous` exactly as it was: change only the words a
      complaint names.
    TEXT

    PROPOSE_INSTRUCTIONS = <<~TEXT
      You build vocabulary cards from Portuguese texts. The input has three
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
        rendering of this sentence. In "sentou-se no banco" the banco is a
        "bench", so a sense "bank" does not fit.
      - "new": no listed sense covers this occurrence. Return a gloss under
        the gloss rules below, an article under the article rules below, and
        no reading. When two occurrences are the same word in the same new
        meaning, give them the identical gloss and article.
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
      article, a typo or a stray letter. Return only the fields a decision
      uses: sense_id for "existing"; gloss, and article for a noun, for
      "new"; note for "missegmented".
    TEXT

    JUDGE_INSTRUCTIONS = <<~TEXT
      You review proposed new senses for a Portuguese vocabulary
      compendium. Another model proposed each one, claiming that none of
      the listed existing senses covers the word as it is used in the
      sentence. The input has three lists. `sentences` gives each sentence
      once. `words` gives each distinct word once: the `headword` it studies
      under and the senses the compendium already holds (`senses`).
      `occurrences` are the proposals: each is one occurrence of a `word`
      (listed under `wid`) in a sentence (`sid`), shown between 【 and 】
      among its neighbours in `marked`, with the proposed headword, article
      and gloss. Nothing enters the compendium unless you accept it, and a wrong
      entry reaches every learner, so reject whenever you have a concrete
      objection:

      - a listed existing sense already covers this occurrence (say which):
        one covers it only if its gloss could stand in for the word in an
        English rendering of the sentence
      - the gloss is not what this form means in this sentence, or loses
        what the form adds (a past tense glossed as present, a plural as
        singular)
      - the headword is not the word in lower case, or lower-cases a name
        or a title before one, or does not write out the word an
        abbreviation stands for here (D. before a woman's name is "Dona")
      - the article breaks the article rules below: a noun without one, one
        that does not fit this form, or one on a word or name that takes
        none
      - another occurrence proposes the same word in the same meaning under a
        different gloss: accept the better wording and reject the other
      - the "word" is not a word, but a fragment of bad segmentation, or a
        whole the segmentation rules below would split
      - the gloss holds Portuguese, a dictionary form, grammar labels,
        several unrelated meanings, or explanation beyond a short gloss
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
      You file Portuguese vocabulary by part of speech. Each item gives a
      headword, in the form a text used it, and one English gloss; choose the
      category that fits the word in that meaning. Use "contraction" for a
      preposition joined to an article or pronoun (do, pela, dele), "verb"
      for a verb with joined pronouns (diga-me), "proper noun" for names of
      people, places and works, "phrase" for a multi-word expression that is
      none of the others, and "other" only when nothing else fits.
    TEXT

    CATEGORIES = [
      "noun",
      "verb",
      "adjective",
      "adverb",
      "pronoun",
      "article",
      "preposition",
      "contraction",
      "conjunction",
      "numeral",
      "interjection",
      "proper noun",
      "phrase",
      "other",
    ].freeze

    PROMPTS = Prompts.new(
      segment: [SEGMENT_INSTRUCTIONS, SEGMENTATION].join("\n").freeze,
      propose: [PROPOSE_INSTRUCTIONS, GLOSSES, ARTICLES, SEGMENTATION]
        .join("\n").freeze,
      judge: [JUDGE_INSTRUCTIONS, GLOSSES, ARTICLES, SEGMENTATION]
        .join("\n").freeze,
      categorize: CATEGORIZE,
      categories: CATEGORIES,
      refine: [GLOSSES, ARTICLES].join("\n").freeze,
    )
  end
end
