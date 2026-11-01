# frozen_string_literal: true

# What processing a snippet needs to know about the language it is written
# in: where its sentences end, which characters make a token a word to give
# a sense, and what to ask a model about it. The segmenter gives each word
# the form it studies under as `form`, which `form_fits` checks against the
# word; `piece` cuts a sentence the segmenter fails on twice. How its
# entries are stored is its `lexicon`'s: a language without `readings`
# takes new senses with a gloss alone, a noun in a language with
# `articles` takes the definite article that fits its form, and a language
# with `traditional` forms gets each word's traditional form from the
# segmenter too, which `form_fits` checks the same way. `skips` are the
# reasons the segmenter may give for a word to get no card. A language
# written with `spaces` between its words breaks lines at them. A language
# that `respells` lets a word study under another spelling than the text's,
# which is judged and reviewed once and then remembered as a `Spelling`.
Language = Data.define(
  :code,
  :sentence,
  :word_char,
  :piece,
  :form,
  :form_fits,
  :lexicon,
  :skips,
  :spaces,
  :respells,
  :prompts,
)

class Language
  # A word's simplified form is written character for character.
  MANDARIN = new(
    code: "zh",
    sentence: /[^。！？\n]+[。！？]*[」』”’）》]*/,
    word_char: /\p{Han}/,
    piece: /./,
    form: "simplified",
    form_fits: ->(text, form) { form.length == text.length },
    lexicon: Lexicon::MANDARIN,
    skips: [],
    spaces: false,
    respells: false,
    prompts: Snippets::Mandarin::PROMPTS,
  )
  # An abbreviation (Sr., Pe.) studies under the word it stands for, which
  # keeps its letters in order from the first.
  ABBREVIATION =
    lambda do |text, form|
      letters = text.delete_suffix(".").chars.map { Regexp.escape(it) }
      text.end_with?(".") && form.match?(/\A#{letters.join("[^.]*")}[^.]*\z/i)
    end
  # In a language written in letters, a word studies under its own form,
  # lower-cased unless it is a name or a title before one, and an
  # abbreviation under the word written out.
  AS_WRITTEN =
    lambda do |text, form|
      form.casecmp?(text) || ABBREVIATION.call(text, form)
    end
  BARE_LETTERS =
    ->(text) { text.unicode_normalize(:nfd).gsub(/\p{M}/, "").downcase }
  # A word the text spells informally studies under its standard spelling,
  # which nothing mechanical can check. Dropping an accent is still refused.
  STANDARD_FORM =
    lambda do |text, form|
      AS_WRITTEN.call(text, form) ||
        (form.present? && BARE_LETTERS.call(text) != BARE_LETTERS.call(form))
    end
  LETTERED_PIECE = /[\p{L}\p{M}\p{N}'’-]+|\S/
  # A sentence in a language written in letters runs on past a full stop
  # after one of its titles or an initial (J. R. Ward), past an ending
  # followed by a lower-case word: the speech tag after a line of dialogue,
  # or a trailing-off ellipsis, and past punctuation inside a word, number
  # or emoticon (5.07, sh!t, =.=). A capital after it starts a new sentence,
  # for a text that leaves out the space.
  LETTERED_SENTENCE =
    lambda do |titles|
      /
        (?:
          \b(?:#{titles.join("|")}|[[:upper:]])\. |
          [.!?…]+[”»"’)*]*(?=\s+[—–]?\s*[[:lower:]]) |
          [.!?…]+(?=[^\s.!?…”»"’)*\p{Lu}]) |
          [^.!?…\n]
        )+
        [.!?…]*[”»"’)*]*
      /x
    end
  # Titles whose full stop doesn't end a sentence: Senhor, Doutora, Padre,
  # Frei, Santo and the like, and the St. of names left in English.
  PORTUGUESE_TITLES =
    "Sr Sra Srta Dr Dra Prof Profa Pe Fr Sto Sta St".split.freeze
  PORTUGUESE = new(
    code: "pt",
    sentence: LETTERED_SENTENCE.call(PORTUGUESE_TITLES),
    word_char: /\p{L}/,
    piece: LETTERED_PIECE,
    form: "headword",
    form_fits: AS_WRITTEN,
    lexicon: Lexicon::PORTUGUESE,
    skips: ["foreign", "name"],
    spaces: true,
    respells: false,
    prompts: Snippets::Portuguese::PROMPTS,
  )
  # Ginoo, Ginang, Binibini, Doktor, and the Spanish and English titles a
  # text may keep: Santo, Santa, Mister.
  FILIPINO_TITLES =
    "G Gng Bb Dr Dra Sr Sra Srta Pe Sto Sta Mr Mrs Ms".split.freeze
  # A word keeps its accents and affixes, and studies under its standard
  # spelling.
  FILIPINO = new(
    code: "fil",
    sentence: LETTERED_SENTENCE.call(FILIPINO_TITLES),
    word_char: /\p{L}/,
    piece: LETTERED_PIECE,
    form: "headword",
    form_fits: STANDARD_FORM,
    lexicon: Lexicon::FILIPINO,
    skips: ["emoticon", "foreign", "name"],
    spaces: true,
    respells: true,
    prompts: Snippets::Filipino::PROMPTS,
  )
  ALL = [MANDARIN, PORTUGUESE, FILIPINO].index_by(&:code).freeze

  def self.for(code) = ALL.fetch(code)
  def self.supported?(code) = ALL.key?(code)

  delegate :readings, :articles, :articles?, :traditional, to: :lexicon

  def word?(text) = text.to_s.match?(word_char)
  def word_chars(text) = text.scan(word_char).join
end
