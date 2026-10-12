# frozen_string_literal: true

module Snippets
  # Saves a snippet and its sentences as the next section of a source.
  module Create
    def self.call(source:, **attributes)
      snippet = source.snippets.build(attributes)
      build_sentences(snippet)

      Result.new(success: snippet.save, record: snippet)
    end

    def self.build_sentences(snippet)
      SplitSentences.call(snippet.body.to_s).each_with_index do |body, position|
        snippet.sentences.build(body:, position:)
      end
    end

    class Result
      attr_accessor :success, :record

      def initialize(success:, record:)
        self.success = success
        self.record = record
      end

      def success? = success
    end
  end
end
