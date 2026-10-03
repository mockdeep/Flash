# frozen_string_literal: true

# One sentence of a snippet. `tokens` holds the pieces it was cut into, in
# order, each a hash of "text" as written and, for a word, the "sense_id" it
# is studied as. Punctuation and other non-words will have no sense_id.
class SnippetSentence < ApplicationRecord
  belongs_to :snippet

  validates :snippet, :body, :position, presence: true
end
