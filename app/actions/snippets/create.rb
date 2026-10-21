# frozen_string_literal: true

module Snippets
  # Saves a snippet and its sentences as the next section of a source, its
  # heading first as a sentence of its own, so the heading's words get cards
  # too.
  module Create
    def self.call(source:, **attributes)
      snippet = source.snippets.build(attributes)
      build_sentences(snippet)

      Result.new(success: snippet.save, record: snippet)
    end

    def self.build_sentences(snippet)
      body = SplitSentences.call(snippet.body.to_s, snippet.language)
      lines = body.map { ["body", it] }
      heading = snippet.heading.to_s.strip
      lines.unshift(["heading", heading]) if heading.present?

      source = snippet.source
      lines.each_with_index do |(role, text), position|
        snippet.sentences.build(source:, role:, body: text, position:)
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
