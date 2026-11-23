# frozen_string_literal: true

# A selection of study content that decks point at. Basic and Music moved to
# flat deck-owned cards, so every word_list is a language list; the compendium
# distinguishes kinds (HSK level, chapter, curated) by column, not by class.
class WordList < ApplicationRecord
  # Codes ISO 639-2 reserves for non-languages (undetermined, no linguistic
  # content, local use); collective families ("Bantu languages") are filtered
  # by name below.
  SPECIAL_CODES = ["und", "zxx", "qaa-qtz"].freeze
  # ISO names zh "Chinese", but what the app studies under it is Mandarin.
  RENAMED = { "zh" => "Mandarin" }.freeze

  # Every individual ISO 639-2 language, code => display name, keyed by the
  # shortest available code (BCP 47 convention: "zh", not "zho") so stored
  # values work as language tags for future speech features. Nothing in the
  # app creates a word_list any more, so this validates what the seed account
  # and catalog copies carry. Only zh gets dedicated study-page treatment
  # (fonts, prewarming) so far.
  language_pairs =
    ISO_639::ISO_639_2.filter_map do |entry|
      name = entry.english_name.split(";").first
      next if SPECIAL_CODES.include?(entry.alpha3) ||
        name.match?(/languages/i)

      code = entry.alpha2.presence || entry.alpha3
      [code, RENAMED.fetch(code, name)]
    end
  LANGUAGES = language_pairs.sort_by(&:last).to_h.freeze
  VISIBILITIES = ["public", "private"].freeze

  belongs_to :user
  has_many :sense_memberships, dependent: :destroy
  has_many :senses, through: :sense_memberships
  has_many :decks, dependent: :restrict_with_exception
  has_one :source, dependent: :destroy
  has_many :snippets, through: :source

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :language, presence: true, inclusion: { in: LANGUAGES.keys }
  validates :visibility, inclusion: { in: VISIBILITIES }
  # Checked only on the way to public, so a list already there can still be
  # saved when its source changes.
  validate(:source_can_be_shown, if: :will_save_change_to_visibility?)

  # The lists a learner's reading map shows: public ones, sources they
  # own or were let read, and any list they have a deck for. A source's
  # list shows only once it has a snippet to read.
  def self.visible_to(user)
    where(visibility: "public")
      .or(where(id: Source.held_by(user).select(:word_list_id)))
      .or(where(id: user.decks.select(:word_list_id)))
      .where.not(id: Source.without_text.select(:word_list_id))
  end

  def publicly_visible? = visibility == "public"

  private

  # A public list comes with its text, so a source's needs a license that
  # lets it be shared and a finished snippet to read.
  def source_can_be_shown
    return unless publicly_visible? && source
    return if source.shareable? && source.studyable?

    errors.add(
      :visibility,
      "can't be public until its source has a shareable license and a " \
      "finished snippet",
    )
  end
end
