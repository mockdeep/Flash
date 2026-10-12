# frozen_string_literal: true

module Snippets
  # The tokens of a sentence cut again, each one the cut left as it was
  # keeping its sense, so resolving asks only about the words that changed.
  # "As it was" is the same text and headword after the same Han characters,
  # which holds however the punctuation around it was cut.
  module Recut
    def self.call(previous, tokens)
      kept =
        placed(previous).filter_map do |place, token|
          [place, token.slice("sense_id", "outcome")] if token["sense_id"]
        end

      senses = kept.to_h
      placed(tokens).map { |place, token| token.merge(senses.fetch(place, {})) }
    end

    def self.placed(tokens)
      han = 0
      tokens.map do |token|
        place = [han, *token.values_at("text", "simplified")]
        han += token["text"].scan(SnippetSentence::HAN).size
        [place, token]
      end
    end
  end
end
