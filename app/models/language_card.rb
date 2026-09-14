# frozen_string_literal: true

# A card over a word_list: the flat content columns stay nil, and every
# reader goes through the compendium. The item is the card's pointer at its
# entry; the list's memberships for that entry give the back, category and
# example. Only the miss-recorded decoys still live on the item.
class LanguageCard < Card
  def self.model_name
    Card.model_name
  end

  has_one :entry, through: :item

  validates :item, presence: true

  delegate :reading, to: :entry

  def front = entry.headword
  def back = memberships.pluck("senses.gloss").join(SEPARATOR)
  def category = memberships.pick(:category)
  def example_front = example&.sentence
  def example_back = example&.translation
  def distractors = item.distractors.map(&:text)

  def homograph?
    deck.cards.joins(item: :entry)
      .where(entries: { headword: front }).where.not(id:).exists?
  end

  private

  # The list's memberships for this card's entry, in the list's gloss order.
  def memberships
    deck.word_list.sense_memberships.joins(:sense)
      .where(senses: { entry_id: item.entry_id }).order(:position)
  end

  # The earliest sentence any of the card's senses holds; a sense shared
  # between lists can carry one from each.
  def example
    return @example if defined?(@example)

    @example = SenseExample
      .where(sense_id: memberships.unscope(:order).select(:sense_id))
      .order(:id).first
  end

  # A language miss accretes an item-side decoy, not a card_distractors row.
  def record_distractor(text)
    WordLists::Projection.add_distractor(self, text)
  end
end
