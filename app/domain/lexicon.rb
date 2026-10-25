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
    categories: German::CATEGORIES,
    refine: German::RULES,
  )
  # Its lists file words by topic rather than part of speech. Only the A1
  # list's nouns have their articles so far.
  SPANISH = new(
    code: "es",
    readings: false,
    articles: ["el", "la", "los", "las"],
    traditional: false,
    categories: Spanish::CATEGORIES,
    refine: Spanish::RULES,
  )
  # An article cut short before a vowel (l') joins its noun without a
  # space.
  ITALIAN = new(
    code: "it",
    readings: false,
    articles: ["il", "lo", "la", "l'", "i", "gli", "le"],
    traditional: false,
    categories: Italian::CATEGORIES,
    refine: Italian::RULES,
  )
  ALL = [
    MANDARIN,
    PORTUGUESE,
    GERMAN,
    SPANISH,
    ITALIAN,
  ].index_by(&:code).freeze

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
