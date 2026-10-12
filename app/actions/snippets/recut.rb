# frozen_string_literal: true

module Snippets
  # The tokens of a sentence cut again, each one the cut left as it was
  # keeping its sense, so resolving asks only about the words that changed.
  # "As it was" is the same text and headword after the same word characters,
  # which holds however the punctuation around it was cut.
  module Recut
    def self.call(sentence, tokens)
      language = sentence.language
      kept =
        placed(sentence.tokens, language).filter_map do |place, token|
          [place, token.slice("sense_id", "outcome")] if token["sense_id"]
        end

      senses = kept.to_h
      placed(tokens, language).map do |place, token|
        token.merge(senses.fetch(place, {}))
      end
    end

    def self.placed(tokens, language)
      chars = 0
      tokens.map do |token|
        place = [chars, *token.values_at("text", "headword")]
        chars += language.word_chars(token["text"]).size
        [place, token]
      end
    end
  end
end
