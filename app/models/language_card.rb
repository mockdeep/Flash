# frozen_string_literal: true

# Shared behavior for cards over a word_list: their content still lives on
# word_list items (the flat card columns stay nil until the compendium
# lands), so the column-backed readers are overridden with item-backed ones.
# Never instantiated directly.
class LanguageCard < Card
  def self.model_name
    Card.model_name
  end

  validates :item, presence: true

  delegate :reading, :category, to: :item

  def front = item.text
  def back = item.glosses.join(SEPARATOR)
  def example_front = item.example
  def example_back = item.paired_example
  def distractors = item.distractors.map(&:text)

  private

  # A language miss accretes an item-side decoy (shared with the reverse
  # deck's projection), not a card_distractors row.
  def record_distractor(text)
    WordLists::Projection.add_distractor(self, text)
  end
end
