# frozen_string_literal: true

# One section of a source, under an optional heading, whose words feed the
# source's word_list.
class Snippet < ApplicationRecord
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 20_000

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

  # The sentences grouped by the body's lines, which splitting drops. No
  # sentence spans a line, so each line holds as many as it splits into.
  def paragraphs
    remaining = sentences.to_a
    body.split(/\s*\n\s*/).compact_blank.map do |line|
      remaining.shift(Snippets::SplitSentences.call(line, language).size)
    end
  end
end
