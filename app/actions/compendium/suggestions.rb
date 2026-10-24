# frozen_string_literal: true

module Compendium
  # The refiner's suggestion files, worked through in a Claude Code session
  # (.claude/skills/compendium-refine). A suggestion leaves its file once
  # applied or dismissed, and the file goes with its last one. A file is
  # stale once a sense of its entries changes after it was written, or an
  # entry goes; its suggestions may no longer fit, so they are not applied.
  # Applying one rewrites the file's time, so the rest of it stays fresh.
  module Suggestions
    class Stale < StandardError; end

    def self.apply(path, index, edits: nil)
      file = read(path)
      raise(Stale, "#{path}: its entries changed since") if stale?(file)

      edits = edits&.map(&:stringify_keys)
      edits ||= file["suggestions"][index]["edits"]
      ActiveRecord::Base.transaction { Edits.new(file["language"]).run(edits) }
      remove(path, file, index)
    end

    def self.dismiss(path, index) = remove(path, read(path), index)

    def self.stale(dir = Refine::DIR)
      Dir[dir.join("*.json")].select { stale?(read(it)) }
    end

    def self.read(path) = JSON.parse(File.read(path))

    def self.stale?(file)
      ids = file["entry_ids"]
      written = Time.iso8601(file["reviewed_at"])

      Entry.where(id: ids).count < ids.size ||
        Sense.exists?(entry_id: ids, updated_at: written..)
    end

    def self.remove(path, file, index)
      file["suggestions"].delete_at(index)
      return File.delete(path) if file["suggestions"].empty?

      file["reviewed_at"] = Time.current.iso8601(6)
      File.write(path, JSON.pretty_generate(file))
    end

    # Runs a suggestion's edits in order. A sense is named by id, or as
    # "new N" for the Nth sense its `add` edits made. A repointed token's
    # snippet is finished again afterwards, so it can still be pushed.
    class Edits
      def initialize(language)
        @language = language
        @made = []
        @snippets = []
      end

      def run(edits)
        edits.each do |edit|
          action = Flag::ACTIONS.find { it == edit["action"] }
          raise(ArgumentError, "Unknown edit: #{edit["action"]}") unless action

          public_send(action, edit)
        end
        @snippets.uniq.each { Snippets::Finish.call(it) }
      end

      def revise(edit)
        changes = edit.slice("gloss", "reading", "article", "traditional")
        Edit.revise(sense(edit), **changes.symbolize_keys)
      end

      def add(edit)
        added = Edit.add(
          language: @language,
          **edit.slice("headword", "gloss", "article").symbolize_keys,
          reading: edit["reading"],
        )
        traditional = edit["traditional"]
        if traditional && added.previously_new_record?
          added.update!(traditional:)
        end
        @made << added
      end

      def remove(edit) = Edit.remove(sense(edit))

      def attach(edit)
        Edit.attach(sense(edit), list(edit), category: edit["category"])
      end

      def detach(edit) = Edit.detach(sense(edit), list(edit))

      def recategorize(edit)
        Edit.recategorize(sense(edit), list(edit), category: edit["category"])
      end

      def repoint(edit)
        sentence = SnippetSentence.find(edit["sentence_id"])
        Snippets::Review.repoint(sentence, edit["token"], sense(edit))
        @snippets << (sentence.snippet || sentence.source.snippets.first)
      end

      private

      def sense(edit)
        name = edit["sense"]
        made = name[/\Anew (\d+)\z/, 1]

        made ? @made[Integer(made)] : Sense.find(Integer(name))
      end

      def list(edit) = WordList.find(edit["list_id"])
    end
  end
end
