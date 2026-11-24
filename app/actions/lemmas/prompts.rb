# frozen_string_literal: true

class Lemmas
  # The system prompt for each language Lemmas can answer for: what counts
  # as a word's base form there, and what else a list may hold it under.
  module Prompts
    PORTUGUESE = <<~TEXT
      You give the dictionary base form of Brazilian Portuguese words, as a
      learner's dictionary lists them. For each item you get a word form as
      written and the sentence it appears in. Answer with:
      - kind: "word"; "name" for a person's or place's name or other proper
        noun (Itaguaí, Bacamarte, Corão, Rio de Janeiro); "numeral" for a
        Roman numeral; "interjection" for an exclamation that is only a
        sound of feeling (ah, oh, ai, hum), not a word used as one (Deus!).
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

    FILIPINO = <<~TEXT
      You give the dictionary base form of Filipino (Tagalog) words, as a
      learner's dictionary lists them. For each item you get a word form as
      written and the sentence it appears in. Answer with:
      - kind: "word"; "name" for a person's or place's name or other proper
        noun (Juan, Maynila, Pilipinas); "numeral" for a Roman numeral;
        "interjection" for an exclamation that is only a sound of feeling
        (ay, aray, hoy), not a word used as one (Diyos ko!).
      - lemmas: the base form(s), lower case.
        A verb gives its plain form with the same affix and focus, without
        its aspect: kumakain, kakain, kumain → kumain; kinakain, kakainin,
        kinain → kainin; nagluluto, magluluto, nagluto → magluto; binigyan,
        bibigyan → bigyan; ikinuwento → ikuwento; nakikita, makikita, nakita
        → makita; pinakain → pakainin. Never give only the root (kain) for a
        verb, and never change its focus.
        An adjective gives its plain form: a plural (magaganda → maganda) and
        an intensive or comparing form (napakaganda, pinakamaganda,
        kasingganda → maganda). A noun is given as it is.
        Drop a linker joined to the word (magandang → maganda; isang → isa;
        haring → hari; kong → ko; itong → ito; wala nang → wala, na), but keep
        an -ng or -g that belongs to the word (ang, nang, kung, hanggang).
        A piece left by an apostrophe gives the word it stands for (y → ay;
        t → at; hangga → hanggang), and a contraction written as one word
        gives each part (sakin → sa, akin).
        A word that repeats itself (araw-araw, sari-sari) or is hyphenated
        (pag-ibig, mag-aral) stays whole. Names get their own form as the
        lemma.
      - alternatives: other headwords a dictionary might list the same word
        under, lower case: another standard spelling (kaniya → kanya; lalake →
        lalaki), the plain verb behind a form for many doers or a repeated
        act (nagsialis → umalis; nagtakbuhan → tumakbo), and for every verb
        the root it is built on (kumain, kainin → kain; magbigay, bigyan →
        bigay; makarating → dating; lumapit → lapit). Empty when there are
        none.
    TEXT

    BY_LANGUAGE = { "pt" => PORTUGUESE, "fil" => FILIPINO }.freeze
  end
end
