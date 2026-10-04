# frozen_string_literal: true

module Snippets
  # Saves a snippet and its sentences under the user's word_list of the given
  # name, made here as a Mandarin list when new.
  module Create
    def self.call(user:, list_name: nil, title: nil, body: nil, author: nil)
      word_list = user.word_lists.find_or_initialize_by(name: list_name)
      word_list.language ||= Snippet::LANGUAGE
      snippet = word_list.snippets.build(title:, author:, body:)
      build_sentences(snippet)

      Result.new(success: save(word_list, snippet), record: snippet)
    end

    def self.build_sentences(snippet)
      SplitSentences.call(snippet.body.to_s).each_with_index do |body, position|
        snippet.sentences.build(body:, position:)
      end
    end

    def self.save(word_list, snippet)
      valid = [word_list.valid?, snippet.valid?].all?
      word_list.errors.each do |error|
        snippet.errors.add(:base, "List #{error.attribute} #{error.message}")
      end

      # Saving the list saves the new snippet and its sentences with it.
      valid && word_list.save!
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
