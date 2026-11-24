# frozen_string_literal: true

module Backbones
  # The words of a text above its level: those whose base form no word list
  # at or below the level holds, unless the backbone's story needs them or
  # they are a title before a name or part of a phrase the lists hold
  # whole (em cima, ao redor de). Names, numerals and interjections (ah, oh)
  # always pass. Where the backbone matches by family, a listed word also
  # counts under its other headwords, so a form of its root passes (bigyan
  # beside magbigay). At a level that isn't strict the result is only a
  # report.
  module Check
    WORD = /\p{L}+(?:-\p{L}+)*/
    SENTENCE_END = /(?<=[.!?:;…])\s+|\n+/

    # A base form above the level, the forms the text writes it in with
    # their counts, and the lowest level whose list holds it (nil for none).
    Flag = Data.define(:base, :forms, :listed)

    Result = Data.define(:words, :flags, :unknown, :strict)

    class Result
      def clean? = !strict || (flags.empty? && unknown.empty?)
    end

    def self.call(backbone, level, text, lemmas:)
      words = lemmas.for(occurrences(text))
      listed = listed(backbone, lemmas)
      forms = above_level(backbone, level, words, listed)

      Result.new(
        words: words.count(&:word?),
        flags: flags(backbone, forms, listed),
        unknown: words.select(&:unknown?).map(&:form).uniq,
        strict: level.strict,
      )
    end

    def self.occurrences(text)
      text.split(SENTENCE_END).flat_map do |sentence|
        sentence.scan(WORD).map { [it, sentence] }
      end
    end

    # The lowest level each headword is listed at, by its lower-case form;
    # a reflexive verb counts under its bare verb too.
    def self.listed(backbone, lemmas)
      backbone.levels.reverse.each_with_object({}) do |level, listed|
        headwords = headwords(level)
        headwords += families(headwords, lemmas) if backbone.families?
        headwords.each { listed[it] ||= level.code }
      end
    end

    # The other headwords for each single word a list holds, its root among
    # them where the language's base forms give one.
    def self.families(headwords, lemmas)
      words = headwords.reject { it.include?(" ") }.uniq

      lemmas.for(words.map { [it, it] }).flat_map(&:alternatives)
    end

    def self.headwords(level)
      memberships = WordList.find_by!(name: level.list).sense_memberships
      memberships.flat_map do |membership|
        headword = membership.sense.entry.headword.downcase
        [headword, headword.delete_prefix("se ")]
      end
    end

    # Each base form above the level, with the forms written for it.
    def self.above_level(backbone, level, words, listed)
      passes = passing(backbone, level, listed)
      phrased = phrased(words, phrases(backbone, level, listed))
      counted(backbone, words, phrased, passes)
    end

    def self.counted(backbone, words, phrased, passes)
      forms = Hash.new { |hash, base| hash[base] = Hash.new(0) }

      words.each_with_index do |word, index|
        next if !word.word? || phrased.include?(index)
        next if title?(backbone, words, index)

        above(word, passes).each { forms[it][word.form] += 1 }
      end
      forms
    end

    # The headwords of more than one word listed at or below the level, as
    # their words.
    def self.phrases(backbone, level, listed)
      codes = backbone.up_to(level).map(&:code)

      listed.filter_map do |headword, code|
        headword.split if headword.include?(" ") && codes.include?(code)
      end
    end

    # The places of the words that make up a listed phrase, each matched as
    # written or by a base form, so "ao redor da" matches "ao redor de".
    def self.phrased(words, phrases)
      words.each_index.with_object(Set.new) do |start, phrased|
        phrases.each do |phrase|
          next unless phrase_at?(words, start, phrase)

          phrased.merge(start...(start + phrase.size))
        end
      end
    end

    def self.phrase_at?(words, start, phrase)
      span = words[start, phrase.size]
      span.size == phrase.size &&
        phrase.zip(span).all? do |part, word|
          word.form.downcase == part || word.lemmas.include?(part)
        end
    end

    def self.passing(backbone, level, listed)
      codes = backbone.up_to(level).map(&:code)
      story = backbone.story_words(level)

      ->(base) { codes.include?(listed[base]) || story.include?(base) }
    end

    def self.title?(backbone, words, index)
      backbone.title_words.include?(words[index].form.downcase) &&
        words[index + 1]&.name?
    end

    # The word's base forms above the level; none when the form as written,
    # or another headword for it, is at or below the level.
    def self.above(word, passes)
      written = passes.call(word.form.downcase)
      return [] if written || word.alternatives.any?(&passes)

      word.lemmas.reject(&passes)
    end

    def self.flags(backbone, forms, listed)
      order = backbone.levels.reverse.map(&:code)
      flags =
        forms.map do |base, counts|
          Flag.new(base:, forms: counts, listed: listed[base])
        end

      flags.sort_by { [order.index(it.listed) || order.size, it.base] }
    end
  end
end
