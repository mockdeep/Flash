# frozen_string_literal: true

module Snippets
  # Puts a traditional source's spelling of each word on the sense it studies
  # as, since each traditional spelling of a meaning is studied on its own.
  # A sense whose spelling no traditional source has written, a guess, takes
  # the text's. One whose spelling such a source has written keeps it, and
  # the token moves to a sibling of the same gloss spelled as this text
  # spells it. A simplified source says nothing about spelling and is left
  # alone.
  module Spell
    def self.call(snippet)
      return unless snippet.source.traditional?

      snippet.sentences_with_front_matter.each { respell(it) }
    end

    def self.respell(sentence)
      tokens =
        sentence.tokens.map do |token|
          next token unless spells?(token)

          sense = spelled(Sense.find(token["sense_id"]), token["text"])
          token.merge("sense_id" => sense.id)
        end
      sentence.update!(tokens:)
    end

    # A word still in review, which a finished one no longer is. A
    # "traditional" key says the text's spelling isn't the Taiwan form.
    def self.spells?(token)
      token.key?("outcome") && token.key?("sense_id") &&
        !token.key?("traditional")
    end

    def self.spelled(sense, spelling)
      return sense if sense.traditional == spelling

      if written?(sense)
        sense.entry.senses
          .find_or_create_by!(gloss: sense.gloss, traditional: spelling)
      else
        sense.tap { it.update!(traditional: spelling) }
      end
    end

    def self.written?(sense)
      written = [{ sense_id: sense.id, text: sense.traditional }].to_json

      SnippetSentence.where(source: Source.traditional)
        .exists?(["tokens @> ?", written])
    end
  end
end
