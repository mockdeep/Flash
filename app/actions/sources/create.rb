# frozen_string_literal: true

module Sources
  # Saves a source and the Mandarin word_list its snippets will fill, named
  # after it.
  module Create
    def self.call(user:, **attributes)
      title = attributes[:title]
      word_list = user.word_lists.build(name: title, language: Snippet::LANGUAGE)
      source = word_list.build_source(attributes)

      Result.new(success: save(word_list, source), record: source)
    end

    def self.save(word_list, source)
      valid = [word_list.valid?, source.valid?].all?
      # The list is named after the source, so a name taken is a title taken.
      word_list.errors.where(:name, :taken).each do |error|
        source.errors.import(error, attribute: :title)
      end

      # Saving the list saves the new source with it.
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
