# frozen_string_literal: true

# One section of a source, under an optional heading, whose words feed the
# source's word_list.
class Snippet < ApplicationRecord
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 80_000
  TOKEN_SENSE_IDS =
    Arel.sql("CAST(jsonb_array_elements(tokens) ->> 'sense_id' AS bigint)")
  # A token in its line, with the sentence it belongs to and its index
  # there; what falls between tokens belongs to none.
  Piece =
    Data.define(:token, :sentence_id, :index) do
      def self.gap(text)
        new(token: { "text" => text }, sentence_id: nil, index: nil)
      end

      def text = token["text"]
    end

  # One line of the body as written, with the sentences it splits into.
  Paragraph =
    Data.define(:text, :sentences) do
      def tokens = pieces.map(&:token)

      # The sentences' tokens, with what the text has between them as pieces
      # of their own: tokens hold no spaces, and the segmenter may leave
      # punctuation out. A token not found as written is kept where it falls.
      def pieces
        rest = text
        found =
          placed.flat_map do |piece|
            at = rest.index(piece.text) or next [piece]
            gap = rest[0...at]
            rest = rest[(at + piece.text.size)..]
            [Piece.gap(gap), piece]
          end
        [*found, Piece.gap(rest)].reject { it.text.empty? }
      end

      private

      def placed
        sentences.flat_map do |sentence|
          sentence.tokens.each_with_index.map do |token, index|
            Piece.new(token:, sentence_id: sentence.id, index:)
          end
        end
      end
    end

  belongs_to :source
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet

  # A push refuses a snippet in progress, so in production one with a
  # segmented sentence is finished. Locally it may still be under review.
  scope :studyable,
        -> { where(id: SnippetSentence.segmented.select(:snippet_id)) }

  validates :source, :body, presence: true
  validates :body, length: { maximum: MAX_BODY }

  delegate :word_list, :language, to: :source

  def title = [source.title, heading].compact_blank.join(" · ")

  # What a learner picks it by: its heading, or its place in its source.
  def label = heading.presence || "Section #{source.snippets.index(self) + 1}"

  # The senses its source's sentences use up to and including it, the
  # title and author among them.
  def sense_ids_through
    SnippetSentence.where(source_id:)
      .where("snippet_id IS NULL OR snippet_id <= ?", id)
      .select(TOKEN_SENSE_IDS)
  end

  # New or finished when every sentence is; in progress otherwise.
  def status
    statuses = sentences.map(&:status).uniq
    return :in_progress if statuses.many?

    statuses.first || :new
  end

  # Its sentences after its source's front matter: what processing,
  # reviewing and finishing a snippet work through, so the source's title
  # and author are done along with whichever snippet comes first.
  def sentences_with_front_matter
    SnippetSentence.where(snippet: self)
      .or(SnippetSentence.where(source_id:, snippet_id: nil))
      .order(Arel.sql("snippet_id NULLS FIRST"), :position)
  end

  # The heading with its sentence, once it has one.
  def heading_paragraph
    Paragraph.new(text: heading, sentences: sentences.select(&:heading?))
  end

  # The body's lines, which splitting drops, each with its sentences. No
  # sentence spans a line, so each line takes the stored sentences found in
  # it, in order, which holds however the splitter has changed since.
  def paragraphs
    remaining = sentences.reject(&:heading?)
    body.split(/\s*\n\s*/).map(&:strip).compact_blank.map do |text|
      Paragraph.new(text:, sentences: take_sentences(text, remaining))
    end
  end

  private

  def take_sentences(text, remaining)
    rest = text
    found =
      remaining.take_while do |sentence|
        at = rest.index(sentence.body)
        rest = rest[(at + sentence.body.size)..] if at
        at
      end

    remaining.shift(found.size)
  end
end
