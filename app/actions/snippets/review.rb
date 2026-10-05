# frozen_string_literal: true

module Snippets
  # The token edits a review makes to a processed snippet, called from a
  # Claude Code session through `bin/rails runner`. A token is named by its
  # sentence and its index there, as `rails snippets:review` prints them.
  # Edits leave the working keys for Finish to strip, and a token given a
  # sense loses its note, since the problem it described is settled. Edits to
  # senses themselves are Compendium::Edit's.
  module Review
    def self.repoint(sentence, index, sense)
      tokens = sentence.tokens.dup
      tokens[index] =
        tokens[index].except("note")
          .merge("outcome" => "matched", "sense_id" => sense.id)
      sentence.update!(tokens:)
    end

    # A sense under the token's headword, made unless the entry for that
    # reading already holds the gloss.
    def self.add_sense(sentence, index, reading:, gloss:)
      headword = Occurrence.new(sentence:, index:).headword
      sense = Compendium::Edit.add(headword:, reading:, gloss:)
      repoint(sentence, index, sense)
      sense
    end

    # Segments the sentence again with the reviewer's complaint and resolves
    # it afresh, without sending it back a second time.
    def self.resegment(sentence, feedback)
      Segment.call([sentence], feedback: { sentence => feedback })
      Resolve.call([sentence], resegment: false)
    end
  end
end
