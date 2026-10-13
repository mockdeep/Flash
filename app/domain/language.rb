# frozen_string_literal: true

# What processing a snippet needs to know about the language it is written
# in: where its sentences end, and which characters make a token a word to
# give a sense, and what to ask a model about it.
Language = Data.define(:code, :sentence, :word_char, :prompts)

class Language
  MANDARIN = new(
    code: "zh",
    sentence: /[^。！？\n]+[。！？]*[」』”’）》]*/,
    word_char: /\p{Han}/,
    prompts: Snippets::Mandarin::PROMPTS,
  )
  # A sentence runs on past a full stop after a title (Sr., Dra.), and past
  # an ending followed by a lower-case word: the speech tag set off by a
  # dash after a line of dialogue, or a trailing-off ellipsis.
  PORTUGUESE = new(
    code: "pt",
    sentence: /
      (?:
        \b(?:Sra?|Srta|Dra?|Profa?)\. |
        [.!?…]+[”»"’)]*(?=\s+[—–]?\s*[[:lower:]]) |
        [^.!?…\n]
      )+
      [.!?…]*[”»"’)]*
    /x,
    word_char: /\p{L}/,
    prompts: nil,
  )
  ALL = [MANDARIN, PORTUGUESE].index_by(&:code).freeze

  def self.for(code) = ALL.fetch(code)
  def self.supported?(code) = ALL.key?(code)

  def word?(text) = text.to_s.match?(word_char)
  def word_chars(text) = text.scan(word_char).join
end
