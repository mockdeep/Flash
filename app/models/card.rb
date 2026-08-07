# frozen_string_literal: true

class Card < ApplicationRecord
  self.ignored_columns += ["status"]

  SEPARATOR = "; "

  # Edit validation adds errors keyed to content fields that now live on
  # data_set items, not card columns. ActiveModel reads the attribute to build
  # the error message, so resolve these virtual keys to nil instead of raising.
  CONTENT_FIELDS = [
    :front, :back, :category, :reading, :example_front, :example_back
  ].freeze

  belongs_to :deck
  belongs_to :item, optional: false
  belongs_to :source_card, class_name: "Card"
  has_many :suggestions, class_name: "CardSuggestion", dependent: :destroy

  validates :deck_id, presence: true
  validates :correct_count, presence: true
  validates :correct_streak, presence: true
  validates :view_count, presence: true

  scope :done, ->(level) { where(correct_streak: level..) }
  scope :not_done, ->(level) { where(correct_streak: ...level) }
  scope :ordered, -> { order(:id) }

  delegate :reading, :category, to: :item

  def done? = correct_streak >= deck.level

  def record_correct!
    self.view_count += 1
    self.correct_count += 1
    self.correct_streak += 1
    save!
  end

  # A miss resets the streak; when the chosen answer is given it's also
  # remembered as a distractor for future option lists (the reading stage
  # passes none - a reading miss never records a translation distractor).
  def record_miss!(chosen_answer = nil)
    self.view_count += 1
    self.correct_streak = 0
    ActiveRecord::Base.transaction do
      save!
      DataSets::Projection.add_distractor(self, chosen_answer) if chosen_answer
    end
  end

  def record_view!
    self.view_count += 1
    save!
  end

  # The card's studyable content, reconstructed from its data_set item (the card
  # itself is a thin progress anchor). Back is the item's glosses rejoined.
  def front = item.text
  def back = item.glosses.join(SEPARATOR)
  def example_front = item.example
  def example_back = item.paired_example
  def distractors = item.distractors.map(&:text)

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

  def read_attribute_for_validation(key)
    CONTENT_FIELDS.include?(key.to_sym) ? nil : super
  end

  def suggestable_to_catalog?
    return false unless source_card

    source_card.deck.visibility == "public" &&
      source_card.deck.user_id != deck.user_id
  end
end
