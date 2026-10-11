# frozen_string_literal: true

module Snippets
  # Lets a user read a snippet whatever its license, and gives them a deck
  # over its word_list to read it from.
  module Grant
    def self.call(snippet:, username:)
      user = User.where.not(role: "guest").find_by(username:)
      return refuse(snippet, username) unless user

      reader = snippet.readers.find_or_initialize_by(user:)
      SnippetReader.transaction do
        reader.save!
        user.reading_deck_over(snippet.word_list)
      end

      Result.new(success: true, record: reader)
    end

    # The failed reader stays off snippet.readers, so the page listing them
    # doesn't show it.
    def self.refuse(snippet, username)
      reader = SnippetReader.new(snippet:)
      reader.errors.add(:base, "No user named #{username}")

      Result.new(success: false, record: reader)
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
