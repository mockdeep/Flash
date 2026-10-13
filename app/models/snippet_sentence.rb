# frozen_string_literal: true

# One sentence of a snippet. `tokens` holds the pieces it was cut into, in
# order, each a hash of "text" as written and, for a word, the "sense_id" it
# is studied as. Punctuation and other non-words will have no sense_id, nor
# will a word the segmenter skipped, which keeps why as "skip".
class SnippetSentence < ApplicationRecord
  TOKEN_KEYS = ["text", "sense_id", "skip"].freeze

  belongs_to :snippet

  validates :snippet, :body, :position, presence: true

  delegate :language, to: :snippet

  scope :unsegmented, -> { where("tokens = '[]'::jsonb") }
  scope :segmented, -> { where.not("tokens = '[]'::jsonb") }
  scope :pointing_at,
        ->(sense) { where("tokens @> ?", [{ sense_id: sense.id }].to_json) }

  # Every sense a token anywhere points at.
  def self.sense_ids
    connection.select_values(<<~SQL.squish).map { |id| Integer(id) }
      SELECT DISTINCT (token ->> 'sense_id')::bigint
      FROM snippet_sentences, jsonb_array_elements(tokens) AS token
      WHERE token ? 'sense_id'
    SQL
  end

  def word_chars = language.word_chars(body)

  # Whether the words rejoin to exactly this sentence's word characters:
  # nothing dropped, invented or substituted. Says nothing about where the
  # boundaries fall.
  def partitioned_by?(words) = language.word_chars(words.join) == word_chars

  # New until segmented. Finished once every word has a sense and
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

  # Segmented, with a word not yet given a sense or an outcome:
  # what resolving works on.
  def awaiting_senses?
    tokens.any? do |token|
      needs_sense?(token) && !token.key?("outcome") && !token.key?("sense_id")
    end
  end

  def needs_sense?(token)
    language.word?(token["text"]) && !token.key?("skip")
  end

  private

  def finished_token?(token)
    (token.keys - TOKEN_KEYS).empty? &&
      (token["sense_id"].present? || !needs_sense?(token))
  end
end
