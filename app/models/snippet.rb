# frozen_string_literal: true

# A source text used for generating a word_list.
class Snippet < ApplicationRecord
  LANGUAGE = "zh"
  # Every sentence costs LLM calls when the snippet is processed, so a
  # pasted novel must not get through; a long work goes in chapter by
  # chapter.
  MAX_BODY = 20_000
  LICENSES = {
    "all_rights_reserved" => { name: "All rights reserved" },
    "public_domain" => { name: "Public domain" },
    "cc_by_sa" => {
      name: "CC BY-SA 4.0",
      url: "https://creativecommons.org/licenses/by-sa/4.0/",
    },
  }.freeze

  belongs_to :word_list
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet

  validates :word_list, :title, :body, presence: true
  validates :body, length: { maximum: MAX_BODY }
  validates :license, inclusion: { in: LICENSES.keys }
  validates :source_url,
            format: { with: %r{\Ahttps?://\S+\z}, allow_blank: true }
  validate(:mandarin)

  def license_name = LICENSES[license][:name]
  def license_url = LICENSES[license][:url]

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
