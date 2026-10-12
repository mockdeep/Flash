# frozen_string_literal: true

module Snippets
  # Cuts a body into sentences on its language's terminal punctuation,
  # keeping any closing quotes or brackets with the sentence they end.
  module SplitSentences
    def self.call(body, language)
      body.scan(language.sentence).map(&:strip).compact_blank
    end
  end
end
