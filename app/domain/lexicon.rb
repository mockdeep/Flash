# frozen_string_literal: true

# How a language's entries are stored, whether or not its texts can be
# processed: whether a sense has a `reading` and a `traditional` form, the
# `articles` a noun's entry takes in place of writing one into its
# headword, the `categories` its lists file words under, and the rules the
# compendium refiner adds to its own (`refine`). A language without a
# lexicon of its own gets a plain one: readings as its entries have them,
# no articles, no categories and no rules.
Lexicon = Data.define(
  :code, :readings, :articles, :traditional, :categories, :refine
)

class Lexicon
  MANDARIN = new(
    code: "zh",
    readings: true,
    articles: [],
    traditional: true,
    categories: Snippets::Mandarin::CATEGORIES,
    refine: [
      Snippets::Mandarin::Policy::FUNCTION_WORDS,
      Snippets::Mandarin::Policy::READING,
    ].join("\n").freeze,
  )
  PORTUGUESE = new(
    code: "pt",
    readings: false,
    articles: ["o", "a", "os", "as"],
    traditional: false,
    categories: Snippets::Portuguese::CATEGORIES,
    refine: [Snippets::Portuguese::GLOSSES, Snippets::Portuguese::ARTICLES]
      .join("\n").freeze,
  )
  GERMAN = new(
    code: "de",
    readings: false,
    articles: ["der", "die", "das"],
    traditional: false,
    categories: [
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
    ].freeze,
    refine: <<~TEXT,
      German rules: a noun's entry is the noun in the nominative with the
      article that fits it, so a learner sees its gender: `article` die and
      headword Arbeit, not der Arbeit (a case form) and not a headword "die
      Arbeit". A noun used only in the plural takes die. A phrase that is
      not a noun as a whole (das ist, die ganze Zeit) keeps its words in
      its headword and takes no article.
    TEXT
  )
  # Its lists file words by topic rather than part of speech. Only the A1
  # list's nouns have their articles so far.
  SPANISH = new(
    code: "es",
    readings: false,
    articles: ["el", "la", "los", "las"],
    traditional: false,
    categories: [
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
    ].freeze,
    refine: <<~TEXT,
      Spanish rules: a noun's entry is the noun with the definite article
      that fits its gender and number in `article`: `article` la and
      headword casa. A feminine noun that takes el before a stressed a (el
      agua) keeps el. A gloss leaves out "the". Many nouns have no article
      yet; that alone is not a problem to suggest fixing.
    TEXT
  )
  ALL = [MANDARIN, PORTUGUESE, GERMAN, SPANISH].index_by(&:code).freeze

  def self.for(code)
    ALL.fetch(code) do
      new(
        code:,
        readings: true,
        articles: [],
        traditional: false,
        categories: [],
        refine: nil,
      )
    end
  end

  def articles? = articles.any?
end
