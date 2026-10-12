# frozen_string_literal: true

# A source text used for generating a word_list.
class Snippet < ApplicationRecord
  LANGUAGE = "zh"
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 20_000

  belongs_to :word_list
  belongs_to :source
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet
  has_many :readers, class_name: "SnippetReader", dependent: :delete_all

  validates :word_list, :title, :body, presence: true
  validates :body, length: { maximum: MAX_BODY }
  validates :license, inclusion: { in: Source::LICENSES.keys }
  validates :source_url,
            format: { with: %r{\Ahttps?://\S+\z}, allow_blank: true }
  validate(:mandarin)

  def license_name = Source::LICENSES[license][:name]
  def license_url = Source::LICENSES[license][:url]
  def shareable? = Source::LICENSES[license].fetch(:shareable, false)

  # Anyone with a deck over the list may read a shareable snippet; the
  # list's owner may read them all, and a reader the one they were let in.
  def readable_by?(user)
    shareable? || word_list.user_id == user.id ||
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

  private

  def mandarin
    return if word_list.nil? || word_list.language == LANGUAGE

    errors.add(:base, "List language must be Mandarin")
  end
end
