# frozen_string_literal: true

module Snippets
  # The words of a language's curriculum lists (Mandarin's HSK lists) that a
  # text writes, so the segmenter keeps them whole and review can spot one
  # it cut. A word counts in its headword or its traditional form; a single
  # character is never cut, so only longer words are looked for.
  class CurriculumWords
    def self.for(language)
      senses =
        Sense.joins(:entry, :sense_memberships).where(
          entries: { language: language.code },
          sense_memberships: { word_list: WordList.where(curriculum: true) },
        )

      new(senses.pluck("entries.headword", :traditional).flatten.compact)
    end

    def initialize(words)
      @words = words.select { it.length > 1 }.to_set
      @longest = @words.map(&:length).max || 0
    end

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
