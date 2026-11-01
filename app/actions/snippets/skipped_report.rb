# frozen_string_literal: true

module Snippets
  # The report's Skipped lines: each skipped word once, with its reason, how
  # often it comes and where first, since a text can leave hundreds of them.
  module SkippedReport
    def self.call(sentences)
      skips =
        sentences.flat_map do |sentence|
          sentence.tokens.each_with_index.filter_map do |token, index|
            next unless token["skip"]

            [token, "sentence #{sentence.id} token #{index}"]
          end
        end

      skips.group_by { |token, _| token.slice("text", "skip") }
        .map { |skip, uses| line(skip, uses) }
    end

    def self.line(skip, uses)
      "  #{skip["text"]}: #{skip["skip"]} " \
        "(#{uses.size}, first at #{uses.first.last})"
    end
  end
end
