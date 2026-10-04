# frozen_string_literal: true

module Snippets
  # Cuts a body into sentences on Chinese terminal punctuation, keeping any
  # closing quotes or brackets with the sentence they end.
  module SplitSentences
    SENTENCE = /[^。！？\n]+[。！？]*[」』”’）》]*/

    def self.call(body)
      body.scan(SENTENCE).map(&:strip).compact_blank
    end
  end
end
