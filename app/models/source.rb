# frozen_string_literal: true

# Where a word_list's snippets come from: an article, a book, or a drawer of
# scraps. It holds what they share, and each snippet is one of its sections.
class Source < ApplicationRecord
  LICENSES = {
    "all_rights_reserved" => { name: "All rights reserved" },
    "public_domain" => { name: "Public domain", shareable: true },
    "cc_by_sa" => {
      name: "CC BY-SA 4.0",
      url: "https://creativecommons.org/licenses/by-sa/4.0/",
      shareable: true,
    },
  }.freeze

  ENTRY_COUNT_COLUMN = <<~SQL.squish
    (#{Deck::ENTRY_COUNT_FROM}
      WHERE sense_memberships.word_list_id = sources.word_list_id)
    AS cards_count
  SQL

  belongs_to :word_list
  has_many :snippets,
           -> { order(:id) },
           dependent: :destroy,
           inverse_of: :source
  # Loaded for every source in a list at once.
  has_many :studyable_snippets,
           -> { studyable },
           class_name: "Snippet",
           inverse_of: false,
           dependent: nil,
           fully_load: true
  has_many :readers, class_name: "SourceReader", dependent: :delete_all
  has_many :reading_places, dependent: :delete_all
  has_one :listing, class_name: "SourceListing", dependent: :delete
  # Its title and author as sentences of their own, so their words are
  # studied too.
  has_many :front_matter,
           -> { where(snippet_id: nil).order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :source

  scope :listed, -> { joins(:listing) }
  scope :with_entry_counts,
        -> { select("sources.*", Arel.sql(ENTRY_COUNT_COLUMN)) }
  scope :traditional, -> { where(script: "traditional") }

  validates :word_list, :title, presence: true
  validates :word_list_id, uniqueness: true
  validates :license, inclusion: { in: LICENSES.keys }
  validates :script, inclusion: { in: LanguageDeck::SCRIPTS }
  validates :source_url,
            format: { with: %r{\Ahttps?://\S+\z}, allow_blank: true }
  validate(:supported_language)

  # The sources a user owns or was let read.
  def self.held_by(user)
    where(word_list: user.word_lists)
      .or(where(id: user.source_readers.select(:source_id)))
  end

  # Those with no snippet to read yet.
  def self.without_text
    where.not(id: Snippet.studyable.select(:source_id))
  end

  def language = Language.for(word_list.language)
  def listed? = listing.present?

  # A text mixing the two stays simplified, so its spellings prove nothing.
  def traditional? = language.traditional && script == "traditional"

  # Where a learner adding the source starts.
  def first_section = snippets.studyable.first

  # An unsaved deck over the whole list, which the catalog shows the source
  # through: its cards, its count and its texts.
  def preview_deck
    ReadingDeck.new(user: word_list.user, word_list:)
      .tap { it.association(:source).target = self }
  end

  def cards_count = self[:cards_count] || preview_deck.cards_count
  def license_name = LICENSES[license][:name]
  def license_url = LICENSES[license][:url]
  def shareable? = LICENSES[license].fetch(:shareable, false)

  # Anyone with a deck over the list may read a shareable source; the
  # list's owner may read any, and a reader the one they were let in.
  def readable_by?(user)
    shareable? || word_list.user_id == user.id ||
      readers.any? { |reader| reader.user_id == user.id }
  end

  def title_paragraph = front_line(title, &:title?)
  def author_paragraph = front_line(author, &:author?)

  # New or finished when every snippet and its front matter is; in progress
  # otherwise.
  def status
    statuses = [*snippets, *front_matter].map(&:status).uniq
    return :in_progress if statuses.many?

    statuses.first || :new
  end

  # Its list only gains senses as snippets are finished.
  def studyable? = studyable_snippets.any?

  private

  def front_line(text, &)
    Snippet::Paragraph.new(text:, sentences: front_matter.select(&))
  end

  def supported_language
    return if word_list.nil? || Language.supported?(word_list.language)

    errors.add(:base, "List language is not supported")
  end
end
