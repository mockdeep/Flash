# frozen_string_literal: true

# What processing a snippet needs to know about the language it is written
# in: where its sentences end, which characters make a token a word to give
# a sense, and what to ask a model about it. The segmenter gives each word
# the form it studies under as `form`, which `form_fits` checks against the
# word; `piece` cuts a sentence the segmenter fails on twice. A language
# without `readings` takes new senses with a gloss alone, and a noun in a
# language with `articles` takes the definite article that fits its form.
# `skips` are the
# reasons the segmenter may give for a word to get no card. A language
# written with `spaces` between its words breaks lines at them.
Language = Data.define(
  :code,
  :sentence,
  :word_char,
  :piece,
  :form,
  :form_fits,
  :readings,
  :articles,
  :skips,
  :spaces,
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
    readings: true,
    articles: [],
    skips: [],
    spaces: false,
    prompts: Snippets::Mandarin::PROMPTS,
  )
  # A sentence runs on past a full stop after a title (Sr., Dra.) or an
  # initial (J. R. Ward), and past an ending followed by a lower-case word:
  # the speech tag set off by a dash after a line of dialogue, or a
  # trailing-off ellipsis. A word studies under its own form, lower-cased
  # unless it is a name.
  PORTUGUESE = new(
    code: "pt",
    sentence: /
      (?:
        \b(?:Sra?|Srta|Dra?|Profa?|[[:upper:]])\. |
        [.!?…]+[”»"’)]*(?=\s+[—–]?\s*[[:lower:]]) |
        [^.!?…\n]
      )+
      [.!?…]*[”»"’)]*
    /x,
    word_char: /\p{L}/,
    piece: /[\p{L}\p{M}\p{N}'’-]+|\S/,
    form: "headword",
    form_fits: ->(text, form) { form.casecmp?(text) },
    readings: false,
    articles: ["o", "a", "os", "as"],
    skips: ["foreign", "name"],
    spaces: true,
    prompts: Snippets::Portuguese::PROMPTS,
  )
  ALL = [MANDARIN, PORTUGUESE].index_by(&:code).freeze

  def self.for(code) = ALL.fetch(code)
  def self.supported?(code) = ALL.key?(code)

  def word?(text) = text.to_s.match?(word_char)
  def word_chars(text) = text.scan(word_char).join
end
