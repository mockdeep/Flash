# frozen_string_literal: true

module Snippets
  # The prompt for a list of occurrences, with nothing said twice: each
  # sentence and each word (its headword and senses) appears once, and the
  # occurrences point at them. A common word would
  # otherwise carry its whole dictionary entry once per occurrence.
  # `proposed` adds to each occurrence the sense a proposer put forward, for
  # the judge.
  module Briefing
    def self.call(occurrences, proposed: [])
      sentences = occurrences.map(&:sentence).uniq
      words = occurrences.uniq(&:spelling)

      {
        sentences: numbered(sentences) { |one, sid| { sid:, text: one.body } },
        words: numbered(words) { |first, wid| first.word_prompt(wid) },
        occurrences:
          prompts(occurrences, sentences, words.map(&:spelling), proposed),
      }
    end

    def self.numbered(list, &) = list.each_with_index.map(&)

    def self.prompts(occurrences, sentences, words, proposed)
      numbered(occurrences) do |occurrence, id|
        sid = sentences.index(occurrence.sentence)
        wid = words.index(occurrence.spelling)

        occurrence.to_prompt(id, sid:, wid:).merge(proposed.fetch(id, {}))
      end
    end
  end
end
