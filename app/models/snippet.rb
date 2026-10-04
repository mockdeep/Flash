# frozen_string_literal: true

# A source text used for generating a word_list.
class Snippet < ApplicationRecord
  LANGUAGE = "zh"
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 20_000

  belongs_to :word_list
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet

  validates :word_list, :title, :body, presence: true
  validates :body, length: { maximum: MAX_BODY }
  validate(:mandarin)

  # New or finished when every sentence is; in progress otherwise.
  def status
    statuses = sentences.map(&:status).uniq
    return :in_progress if statuses.many?

    statuses.first || :new
  end

  private

  def mandarin
    return if word_list.nil? || word_list.language == LANGUAGE

    errors.add(:base, "List language must be Mandarin")
  end
end
