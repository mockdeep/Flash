# frozen_string_literal: true

module Snippets
  # Puts a traditional text's spelling of each word on the sense it studies
  # as, since each traditional spelling of a meaning is studied on its own.
  # A sense whose spelling no text has used yet, a guess, takes the text's.
  # One whose spelling a text has used keeps it, and the token moves to a
  # sibling of the same gloss spelled as this text spells it. A snippet in
  # simplified says nothing about spelling and is left alone; so is one
  # already finished, whose working keys are gone.
  module Spell
    def self.call(snippet)
      return unless traditional?(snippet)

      snippet.sentences_with_front_matter.each { respell(it) }
    end

    # Some word of it simplifies to another form.
    def self.traditional?(snippet)
      snippet.language.traditional &&
        snippet.sentences_with_front_matter.any? do |sentence|
          sentence.tokens.any? { |token| token.key?("headword") }
        end
    end

    def self.respell(sentence)
      tokens =
        sentence.tokens.map do |token|
          next token unless token["sense_id"]

          sense = spelled(Sense.find(token["sense_id"]), token["text"])
          token.merge("sense_id" => sense.id)
        end
      sentence.update!(tokens:)
    end

    def self.spelled(sense, spelling)
      return sense if sense.traditional == spelling

      if used?(sense)
        sense.entry.senses
          .find_or_create_by!(gloss: sense.gloss, traditional: spelling)
      else
        sense.tap { it.update!(traditional: spelling) }
      end
    end

    # A text has used a spelling when a token pointing at the sense is
    # written in it, and the spelling is not also the simplified form.
    def self.used?(sense)
      traditional = sense.traditional
      written = [{ sense_id: sense.id, text: traditional }].to_json

      traditional != sense.entry.headword &&
        SnippetSentence.exists?(["tokens @> ?", written])
    end
  end
end
