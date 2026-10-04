# frozen_string_literal: true

# One sentence of a snippet. `tokens` holds the pieces it was cut into, in
# order, each a hash of "text" as written and, for a word, the "sense_id" it
# is studied as. Punctuation and other non-words will have no sense_id.
class SnippetSentence < ApplicationRecord
  HAN = /\p{Han}/
  TOKEN_KEYS = ["text", "sense_id"].freeze

  belongs_to :snippet

  validates :snippet, :body, :position, presence: true

  scope :unsegmented, -> { where("tokens = '[]'::jsonb") }

  def han = body.scan(HAN).join

  # Whether the words rejoin to exactly this sentence's Han characters:
  # nothing dropped, invented or substituted. Says nothing about where the
  # boundaries fall.
  def partitioned_by?(words) = words.join.scan(HAN).join == han

  # New until segmented. Finished once every Chinese word has a sense and
  # nothing else is left on the tokens: what a sentence must be before it
  # can leave the machine it was processed on.
  def status
    if tokens.empty?
      :new
    elsif tokens.all? { |token| finished_token?(token) }
      :finished
    else
      :in_progress
    end
  end

  private

  def finished_token?(token)
    (token.keys - TOKEN_KEYS).empty? &&
      (token["sense_id"].present? || !token["text"].to_s.match?(HAN))
  end
end
