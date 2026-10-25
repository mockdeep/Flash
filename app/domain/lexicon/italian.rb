# frozen_string_literal: true

class Lexicon
  # Italian's list categories and the rules the refiner adds for it.
  module Italian
    CATEGORIES = [
      "actions",
      "descriptors",
      "places-travel",
      "time-calendar",
      "adverbs",
      "people-family",
      "food-drink",
      "function-words",
      "communication-media",
      "work-school",
      "home",
      "clothing",
      "shopping-money",
      "objects",
      "greetings",
      "question-words",
      "nature-weather",
      "body-health",
    ].freeze

    RULES = <<~TEXT
      Italian rules: a noun's entry is the noun with the definite article
      that fits its gender, its number and its first sound in `article`:
      `article` la and headword casa. Lo and gli go before s and a
      consonant, z, gn, ps and x; l' before a vowel, written with no space
      (`article` l' and headword acqua). A gloss leaves out "the".
    TEXT
  end
end
