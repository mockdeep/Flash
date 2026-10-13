# frozen_string_literal: true

# One section of a source, under an optional heading, whose words feed the
# source's word_list.
class Snippet < ApplicationRecord
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 20_000
  # One line of the body as written, with the sentences it splits into.
  Paragraph =
    Data.define(:text, :sentences) do
      # The sentences' tokens, with what the text has between them as tokens
      # of their own: tokens hold no spaces, and the segmenter may leave
      # punctuation out. A token not found as written is kept where it falls.
      def tokens
        rest = text
        tokens =
          sentences.flat_map(&:tokens).flat_map do |token|
            at = rest.index(token["text"]) or next [token]
            gap = rest[0...at]
            rest = rest[(at + token["text"].size)..]
            [{ "text" => gap }, token]
          end
        [*tokens, { "text" => rest }].reject { it["text"].empty? }
      end
    end

  belongs_to :source
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet

  validates :source, :body, presence: true
  validates :body, length: { maximum: MAX_BODY }

  delegate :word_list, :language, to: :source

  def title = [source.title, heading].compact_blank.join(" · ")

  # New or finished when every sentence is; in progress otherwise.
  def status
    statuses = sentences.map(&:status).uniq
    return :in_progress if statuses.many?

    statuses.first || :new
  end

  # The body's lines, which splitting drops, each with its sentences. No
  # sentence spans a line, so each line holds as many as it splits into.
  def paragraphs
    remaining = sentences.to_a
    body.split(/\s*\n\s*/).map(&:strip).compact_blank.map do |text|
      count = Snippets::SplitSentences.call(text, language).size
      Paragraph.new(text:, sentences: remaining.shift(count))
    end
  end
end
