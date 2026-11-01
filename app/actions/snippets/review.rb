# frozen_string_literal: true

module Snippets
  # The token edits a review makes to a processed snippet, called from a
  # Claude Code session through `bin/rails runner`. A token is named by its
  # sentence and its index there, as `rails snippets:review` prints them.
  # Edits leave the working keys for Finish to strip, and a token given a
  # sense loses its note and any skip, since what they said is settled. Edits to
  # senses themselves are Compendium::Edit's.
  module Review
    def self.repoint(sentence, index, sense)
      tokens = sentence.tokens.dup
      tokens[index] = repointed(tokens[index], sense)
      sentence.update!(tokens:)
    end

    def self.repointed(token, sense)
      fields = { "outcome" => "matched", "sense_id" => sense.id }
      fields["headword"] = sense.entry.headword if token.key?("headword")

      token.except("note", "skip").merge(fields)
    end

    # Repoints every token of a snippet that spells a word `text` and studies
    # it under `headword`, for a respelling the report shows was wrong.
    def self.repoint_spelling(snippet, text, headword, sense)
      snippet.sentences_with_front_matter.each do |sentence|
        sentence.tokens.each_with_index do |token, index|
          next unless token["text"].casecmp?(text)
          next unless token["headword"] == headword

          repoint(sentence, index, sense)
        end
      end
    end

    # A sense under the token's headword, made unless the entry for that
    # reading and article already holds the gloss. A sense it makes takes
    # the token's traditional form.
    def self.add_sense(sentence, index, reading:, gloss:, article: nil)
      occurrence = Occurrence.new(sentence:, index:)
      headword = occurrence.headword
      language = sentence.language.code
      sense =
        Compendium::Edit.add(headword:, reading:, gloss:, language:, article:)
      traditional = occurrence.traditional
      sense.update!(traditional:) if sense.previously_new_record?
      repoint(sentence, index, sense)
      sense
    end

    # Segments the sentence again with the reviewer's complaint and resolves
    # the tokens that changed, without sending it back a second time.
    def self.resegment(sentence, feedback)
      complaint = { sentence => feedback }
      Segment.call([sentence], feedback: complaint)
      Resolve.call([sentence], resegmented: complaint)
    end
  end
end
