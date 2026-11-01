# frozen_string_literal: true

module Snippets
  # Finish's record of how a reviewed snippet spells its words where that
  # differs from their headwords, in a language that respells them.
  module RecordSpellings
    def self.call(snippet)
      return unless snippet.language.respells

      snippet.sentences_with_front_matter.each do |sentence|
        sentence.tokens.each { record(it) }
      end
    end

    def self.record(token)
      sense_id, text = token.values_at("sense_id", "text")
      return unless sense_id

      entry = Sense.find(sense_id).entry
      return if text.casecmp?(entry.headword)

      entry.spellings.find_or_create_by!(text: text.downcase)
    end
  end
end
