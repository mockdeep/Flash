# frozen_string_literal: true

module Snippets
  # The report's Curriculum words cut lines: a curriculum word a sentence
  # writes that no token holds, with the tokens it was cut into, so review
  # can tell a slip from a real difference of meaning ("thing", or "east"
  # and "west" side by side).
  module CurriculumReport
    def self.call(sentences)
      return [] if sentences.empty?

      curriculum = CurriculumWords.for(sentences.first.language)
      cuts(sentences, curriculum).map { |word, cut| line(word, **cut) }
    end

    # Each cut word, with how it was cut and the sentences that cut it.
    def self.cuts(sentences, curriculum)
      sentences.each_with_object({}) do |sentence, cuts|
        texts = sentence.tokens.pluck("text")
        curriculum.found_in(sentence.body).each do |word|
          parts = parts(texts, word)
          (cuts[word] ||= { parts:, ids: [] })[:ids] << sentence.id if parts
        end
      end
    end

    # The neighbouring tokens that write exactly the word, or nil when none
    # do: a token holds it, or it straddles a token's edge by chance, which
    # is no cut.
    def self.parts(texts, word)
      (2..word.length).each do |size|
        found = texts.each_cons(size).find { it.join == word }
        return found.join(" + ") if found
      end
      nil
    end

    def self.line(word, parts:, ids:)
      "  #{word}: cut #{parts} in #{"sentence".pluralize(ids.size)} " \
        "#{ids.join(", ")}"
    end
  end
end
