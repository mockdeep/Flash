# frozen_string_literal: true

class LanguageCard < Card
  def self.model_name
    Card.model_name
  end

  has_one :entry, through: :item

  validates :item, presence: true

  delegate :category, to: :item
  delegate :reading, to: :entry

  def front = entry.headword
  def back = item.glosses.join(SEPARATOR)
  def example_front = item.example
  def example_back = item.paired_example
  def distractors = item.distractors.map(&:text)

  def homograph?
    deck.cards.joins(item: :entry)
      .where(entries: { headword: front }).where.not(id:).exists?
  end

  private

  # A language miss accretes an item-side decoy (shared with the reverse
  # deck's projection), not a card_distractors row.
  def record_distractor(text)
    WordLists::Projection.add_distractor(self, text)
  end
end
