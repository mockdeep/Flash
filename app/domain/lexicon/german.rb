# frozen_string_literal: true

class Lexicon
  # German's list categories and the rules the refiner adds for it.
  module German
    CATEGORIES = [
      "noun-with-article",
      "conjugated-verb",
      "infinitive",
      "imperative-or-participle",
      "adjective-or-adverb",
      "pronoun",
      "preposition",
      "connector",
      "expression",
      "grammar-note",
    ].freeze

    RULES = <<~TEXT
      German rules: a noun's entry is the noun in the nominative with the
      article that fits it, so a learner sees its gender: `article` die and
      headword Arbeit, not der Arbeit (a case form) and not a headword "die
      Arbeit". A noun used only in the plural takes die. A phrase that is
      not a noun as a whole (das ist, die ganze Zeit) keeps its words in
      its headword and takes no article.
    TEXT
  end
end
