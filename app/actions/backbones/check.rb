# frozen_string_literal: true

module Backbones
  # The words of a text above its level: those whose base form no word list
  # at or below the level holds, unless the backbone's story needs them or
  # they are a title before a name. Names and numerals always pass. At a
  # level that isn't strict the result is only a report.
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
      listed = listed(backbone)
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
    def self.listed(backbone)
      backbone.levels.reverse.each_with_object({}) do |level, listed|
        headwords(level).each { listed[it] ||= level.code }
      end
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
      forms = Hash.new { |hash, base| hash[base] = Hash.new(0) }

      words.each_with_index do |word, index|
        next if !word.word? || title?(backbone, words, index)

        above(word, passes).each { forms[it][word.form] += 1 }
      end
      forms
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
