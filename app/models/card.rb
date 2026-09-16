# frozen_string_literal: true

class Card < ApplicationRecord
  include StudyCounters

  self.ignored_columns += ["status"]

  SEPARATOR = "; "

  # A multi-gloss back stores its display form: semicolon parts squished,
  # deduped, and rejoined with the separator.
  NORMALIZE_BACK =
    lambda do |back|
      back.split(";").map(&:squish).compact_blank.uniq.join(SEPARATOR)
    end

  belongs_to :deck
  belongs_to :source_card, class_name: "Card"
  has_many :card_distractors, dependent: :delete_all

  normalizes :back, with: NORMALIZE_BACK

  validates :deck_id, presence: true

  scope :done, ->(level) { where(correct_streak: level..) }
  scope :not_done, ->(level) { where(correct_streak: ...level) }
  scope :ordered, -> { order(:id) }

  def self.backs = pluck(:back)

  def done? = correct_streak >= deck.level

  # A miss resets the streak; when the chosen answer is given it's also
  # remembered as a distractor for future option lists (the reading stage
  # passes none - a reading miss never records a translation distractor).
  def record_miss!(chosen_answer = nil)
    transaction do
      super()
      record_distractor(chosen_answer) if chosen_answer
    end
  end

  def distractors = card_distractors.map(&:text)

  def homograph? = false

  def to_row
    {
      front:,
      back:,
      category:,
      reading:,
      example_front:,
      example_back:,
      distractors:,
    }
  end

  private

  def record_distractor(text)
    card_distractors.find_or_create_by!(text:)
  end
end
