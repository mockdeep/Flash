# frozen_string_literal: true

module Sources
  # Saves a source and the word_list its snippets will fill, named after it
  # and in the language chosen for it, with its title and author as
  # sentences of their own.
  module Create
    def self.call(user:, language: nil, **attributes)
      title = attributes[:title]
      word_list = user.word_lists.build(name: title, language:)
      source = word_list.build_source(attributes)
      build_front_matter(source)

      Result.new(success: save(word_list, source), record: source)
    end

    def self.build_front_matter(source)
      lines = { "title" => source.title, "author" => source.author }
      lines.each_with_index do |(role, text), position|
        body = text.to_s.strip
        source.front_matter.build(role:, body:, position:) if body.present?
      end
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
