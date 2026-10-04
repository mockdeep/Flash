# frozen_string_literal: true

# One sentence of a snippet. `tokens` holds the pieces it was cut into, in
# order, each a hash of "text" as written and, for a word, the "sense_id" it
# is studied as. Punctuation and other non-words will have no sense_id.
class SnippetSentence < ApplicationRecord
  HAN = /\p{Han}/
  TOKEN_KEYS = ["text", "sense_id"].freeze

  belongs_to :snippet

  validates :snippet, :body, :position, presence: true

  # Segmented, every Chinese word given a sense, and nothing else on the
  # tokens: what a sentence must be before it can leave the machine it was
  # made on.
  def finished?
    tokens.any? && tokens.all? { |token| finished_token?(token) }
  end

  private

  def finished_token?(token)
    (token.keys - TOKEN_KEYS).empty? &&
      (token["sense_id"].present? || !token["text"].to_s.match?(HAN))
  end
end
