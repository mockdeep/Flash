# frozen_string_literal: true

module Snippets
  # The phrases of a language's curriculum lists that a text writes, in a
  # language written with spaces: there a single word is never cut, but a
  # phrase (em cima, levar em conta) may be. A phrase is found where its
  # words stand side by side with only spaces between, each written as
  # listed or, where Lemmas knows the language, in a form of it alone
  # (levou em conta; not a contraction, whose other part the phrase would
  # swallow). It is given as the text writes it.
  class CurriculumPhrases
    WORD = /[\p{L}\p{M}]+(?:['’-][\p{L}\p{M}]+)*/
    GAP = /\A\s+\z/

    # A word of a text: its form as written and where it starts and ends.
    Word = Data.define(:form, :from, :to)

    def self.for(language)
      code = language.code
      lemmas = Lemmas.in(code) if Lemmas::LANGUAGES.include?(code)

      new(CurriculumWords.listed(language), lemmas)
    end

    def initialize(headwords, lemmas)
      phrases = headwords.map { it.downcase.split }.select { it.size > 1 }
      @phrases = phrases.uniq.group_by(&:first)
      @lemmas = lemmas
    end

    # For each text, every curriculum phrase it writes, in the order it
    # first does. The texts' base forms are asked for together.
    def found_in_each(texts)
      return texts.map { [] } if @phrases.empty?

      words = texts.map { words_of(it) }
      bases = bases(texts, words)
      texts.zip(words).map { |text, line| found(text, line, bases) }
    end

    private

    def words_of(text)
      text.to_enum(:scan, WORD).map do
        match = Regexp.last_match
        Word.new(form: match.to_s, from: match.begin(0), to: match.end(0))
      end
    end

    # Each form's base form, for a form that has just one.
    def bases(texts, words)
      return {} unless @lemmas

      occurrences =
        texts.zip(words).flat_map do |text, line|
          line.map { [it.form, text] }
        end
      known = @lemmas.for(occurrences).select { it.lemmas.one? }
      known.to_h { [it.form, it.lemmas.sole] }
    end

    def found(text, words, bases)
      spans =
        words.each_index.flat_map do |start|
          starting_with(words[start], bases).filter_map do |phrase|
            span_at(text, words[start, phrase.size], phrase, bases)
          end
        end
      spans.uniq
    end

    def starting_with(word, bases)
      names(word, bases).flat_map { @phrases.fetch(it, []) }
    end

    def names(word, bases) = [word.form.downcase, bases[word.form]].uniq

    # The stretch of the text the words write, when they write the phrase.
    def span_at(text, words, phrase, bases)
      return unless words.size == phrase.size && side_by_side?(text, words)
      return unless phrase.zip(words).all? do |part, word|
        names(word, bases).include?(part)
      end

      text[words.first.from...words.last.to]
    end

    def side_by_side?(text, words)
      words.each_cons(2).all? do |word, following|
        text[word.to...following.from].match?(GAP)
      end
    end
  end
end
