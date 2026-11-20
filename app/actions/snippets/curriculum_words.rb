# frozen_string_literal: true

module Snippets
  # The words of a language's curriculum lists (Mandarin's HSK lists) that a
  # text writes, so the segmenter keeps them whole and review can spot one
  # it cut. A word counts in its headword or its traditional form, and a word
  # ending in the erhua suffix also without it, since texts often drop it; a
  # single character is never cut, so only longer words are looked for.
  # Words are looked for anywhere in a sentence, character by character,
  # which suits a language written without spaces; one written with them
  # has only phrases to keep whole, which CurriculumPhrases finds.
  class CurriculumWords
    ERHUA = /[儿兒]\z/
    def self.for(language)
      return CurriculumPhrases.for(language) if language.spaces

      new(listed(language))
    end

    # Every headword and traditional form on the language's curriculum
    # lists.
    def self.listed(language)
      senses =
        Sense.joins(:entry, :sense_memberships).where(
          entries: { language: language.code },
          sense_memberships: { word_list: WordList.where(curriculum: true) },
        )

      senses.pluck("entries.headword", :traditional).flatten.compact
    end

    def initialize(words)
      @words = words.flat_map { [it, it.sub(ERHUA, "")] }
        .select { it.length > 1 }.to_set
      @longest = @words.map(&:length).max || 0
    end

    def found_in_each(texts) = texts.map { found_in(it) }

    # Every curriculum word the text writes, in the order it first does.
    def found_in(text)
      (0...text.length).flat_map { |start| starting_at(text, start) }.uniq
    end

    private

    def starting_at(text, start)
      (2..@longest).filter_map do |size|
        word = text[start, size]
        word if word.length == size && @words.include?(word)
      end
    end
  end
end
