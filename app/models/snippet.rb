# frozen_string_literal: true

# One section of a source, under an optional heading, whose words feed the
# source's word_list.
class Snippet < ApplicationRecord
  LANGUAGE = "zh"
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 20_000

  # Moved to the source; the columns go once this is deployed.
  self.ignored_columns += ["title", "author", "source_url", "license"]

  belongs_to :word_list
  belongs_to :source
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet
  has_many :readers, class_name: "SnippetReader", dependent: :delete_all

  validates :word_list, :source, :body, presence: true
  validates :body, length: { maximum: MAX_BODY }

  def title = [source.title, heading].compact_blank.join(" · ")

  # Anyone with a deck over the list may read a shareable snippet; the
  # list's owner may read them all, and a reader the one they were let in.
  def readable_by?(user)
    source.shareable? || word_list.user_id == user.id ||
      readers.any? { |reader| reader.user_id == user.id }
  end

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
      remaining.shift(Snippets::SplitSentences.call(line).size)
    end
  end
end
