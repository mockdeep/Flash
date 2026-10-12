# frozen_string_literal: true

module Snippets
  # The prompt for a list of occurrences, with nothing said twice: each
  # sentence and each word (its headword and senses) appears once, and the
  # occurrences point at them. A common word would
  # otherwise carry its whole dictionary entry once per occurrence.
  # `proposed` adds to each occurrence the sense a proposer put forward, for
  # the judge. A sentence already segmented again carries the complaint.
  module Briefing
    def self.call(occurrences, proposed: [])
      firsts = occurrences.uniq(&:sentence)
      words = occurrences.uniq(&:spelling)

      {
        sentences: numbered(firsts) { |one, sid| sentence_prompt(one, sid) },
        words: numbered(words) { |first, wid| first.word_prompt(wid) },
        occurrences: prompts(
          occurrences, firsts.map(&:sentence), words.map(&:spelling), proposed
        ),
      }
    end

    def self.numbered(list, &) = list.each_with_index.map(&)

    def self.sentence_prompt(occurrence, sid)
      text = occurrence.sentence.body
      { sid:, text:, resegmented: occurrence.complaint }.compact
    end

    def self.prompts(occurrences, sentences, words, proposed)
      numbered(occurrences) do |occurrence, id|
        sid = sentences.index(occurrence.sentence)
        wid = words.index(occurrence.spelling)

        occurrence.to_prompt(id, sid:, wid:).merge(proposed.fetch(id, {}))
      end
    end
  end
end
