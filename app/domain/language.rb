# frozen_string_literal: true

# What processing a snippet needs to know about the language it is written
# in: where its sentences end, and which characters make a token a word to
# give a sense.
Language = Data.define(:code, :sentence, :word_char)

class Language
  MANDARIN = new(
    code: "zh",
    sentence: /[^。！？\n]+[。！？]*[」』”’）》]*/,
    word_char: /\p{Han}/,
  )
  ALL = [MANDARIN].index_by(&:code).freeze

  def self.for(code) = ALL.fetch(code)
  def self.supported?(code) = ALL.key?(code)

  def word?(text) = text.to_s.match?(word_char)
  def word_chars(text) = text.scan(word_char).join
end
