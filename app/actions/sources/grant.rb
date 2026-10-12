# frozen_string_literal: true

module Sources
  # Lets a user read a source whatever its license, and gives them a deck
  # over its word_list to read it from.
  module Grant
    def self.call(source:, username:)
      user = User.where.not(role: "guest").find_by(username:)
      return refuse(source, username) unless user

      reader = source.readers.find_or_initialize_by(user:)
      SourceReader.transaction do
        reader.save!
        user.reading_deck_over(source.word_list)
      end

      Result.new(success: true, record: reader)
    end

    # The failed reader stays off source.readers, so the page listing them
    # doesn't show it.
    def self.refuse(source, username)
      reader = SourceReader.new(source:)
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
