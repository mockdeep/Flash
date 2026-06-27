# frozen_string_literal: true

# Reconstructs a card's forward-text content from its data_set item, so study
# and display read from the item rather than the card's own columns (which are
# dropped in a later step). The card's back is its item's glosses rejoined.
class CardContent
  SEPARATOR = "; "

  delegate :reading, :category, to: :item

  def initialize(card)
    @item = card.item
  end

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

  private

  attr_reader :item
end
