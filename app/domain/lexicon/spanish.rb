# frozen_string_literal: true

class Lexicon
  # Spanish's list categories and the rules the refiner adds for it.
  module Spanish
    CATEGORIES = [
      "Work & business",
      "Society & government",
      "Body & health",
      "Transport & travel",
      "Arts & culture",
      "Education",
      "Food & drink",
      "Technology & media",
      "People & personality",
      "Home & living",
      "Nature & environment",
      "Family & social life",
      "Emotions & psychology",
      "Leisure & sport",
      "Clothing & appearance",
      "Geography",
      "General",
    ].freeze

    RULES = <<~TEXT
      Spanish rules: a noun's entry is the noun with the definite article
      that fits its gender and number in `article`: `article` la and
      headword casa. A feminine noun that takes el before a stressed a (el
      agua) keeps el. A gloss leaves out "the". Many nouns have no article
      yet; that alone is not a problem to suggest fixing.
    TEXT
  end
end
