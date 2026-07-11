# frozen_string_literal: true

# A card in a writing deck. It anchors a Back item (the prompt), so the front is
# that item's text (inherited) while the answer and its gloss-side metadata come
# from the paired Front item(s). Distractors are inherited: a writing miss
# accretes a Front-side decoy onto the anchored Back item.
class WritingCard < Card
  def self.model_name
    Card.model_name
  end

  delegate :reading, :category, to: :answer_item

  def back = item.reverse_glosses.join(SEPARATOR)
  def example_front = answer_item.example
  def example_back = answer_item.paired_example

  private

  # The answering Front item - the first one paired to this prompt. A writing
  # card only ever anchors a paired Back item, so there is always one.
  def answer_item = item.inverse_pairings.min_by(&:id).item
end
