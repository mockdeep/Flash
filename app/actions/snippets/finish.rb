# frozen_string_literal: true

module Snippets
  # Closes a reviewed snippet: every Chinese word must have a sense. Strips
  # the pipeline's working keys from its tokens, so the snippet reads
  # finished and can be pushed, adds its senses to its word_list, and files
  # the list's new memberships by category. Safe to run again: a finished
  # snippet only gets whatever filing a failed run left undone.
  module Finish
    CATEGORIZE_BATCH = 50

    class Unfinished < StandardError; end

    def self.call(snippet)
      unsensed!(snippet)
      snippet.transaction do
        snippet.sentences.each { |sentence| strip(sentence) }
        Attach.call(snippet)
      end
      categorize(snippet.word_list)
    end

    def self.unsensed!(snippet)
      words =
        snippet.sentences.flat_map(&:tokens).filter_map do |token|
          text = token["text"]
          text if text.match?(SnippetSentence::HAN) && token["sense_id"].nil?
        end
      return if words.empty?

      raise(Unfinished, "Words without a sense: #{words.uniq.join(", ")}")
    end

    def self.strip(sentence)
      tokens =
        sentence.tokens.map do |token|
          token.slice(*SnippetSentence::TOKEN_KEYS)
        end
      sentence.update!(tokens:)
    end

    def self.categorize(word_list)
      batches = word_list.sense_memberships.uncategorized
        .in_batches(of: CATEGORIZE_BATCH)
      batches.each { |batch| Categorize.call(batch.to_a) }
    end
  end
end
