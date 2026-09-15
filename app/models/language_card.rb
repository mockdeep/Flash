# frozen_string_literal: true

# A card over a word_list: the flat content columns stay nil, and every
# reader goes through the compendium. The item is the card's pointer at its
# entry; the list's memberships for that entry give the back, category and
# example, and the owner's sense_distractors give the remembered decoys.
class LanguageCard < Card
  def self.model_name
    Card.model_name
  end

  has_one :entry, through: :item

  validates :item, presence: true

  def self.backs
    joins(item: { word_list: { sense_memberships: :sense } })
      .where(Sense.arel_table[:entry_id].eq(Item.arel_table[:entry_id]))
      .order("sense_memberships.position")
      .pluck(:id, "senses.gloss")
      .group_by(&:first)
      .values.map { |rows| rows.map(&:last).join(SEPARATOR) }
  end

  delegate :reading, to: :entry

  def front = entry.headword
  def back = list_back(item.entry_id)
  def category = memberships.pick(:category)
  def example_front = example&.sentence
  def example_back = example&.translation

  def distractors
    decoy_entry_ids.filter_map { |id| list_back(id).presence }.uniq
  end

  def homograph?
    deck.cards.joins(item: :entry)
      .where(entries: { headword: front }).where.not(id:).exists?
  end

  private

  def list_memberships = deck.word_list.sense_memberships.joins(:sense)

  # The list's memberships for this card's entry, in the list's gloss order.
  def memberships = memberships_of(item.entry_id)

  def memberships_of(entry_id)
    list_memberships.where(senses: { entry_id: }).order(:position)
  end

  def list_back(entry_id)
    memberships_of(entry_id).pluck("senses.gloss").join(SEPARATOR)
  end

  def sense_ids = memberships.unscope(:order).select(:sense_id)

  def decoy_entry_ids
    SenseDistractor.where(user: deck.user, sense_id: sense_ids)
      .joins(:distractor_sense).distinct.pluck("senses.entry_id")
  end

  # The earliest sentence any of the card's senses holds; a sense shared
  # between lists can carry one from each.
  def example
    return @example if defined?(@example)

    @example = SenseExample.where(sense_id: sense_ids).order(:id).first
  end

  def record_distractor(text)
    memberships.pluck(:sense_id).product(chosen_sense_ids(text)).each do
      |sense_id, distractor_sense_id|
      miss = SenseDistractor.find_or_initialize_by(
        user_id: deck.user_id, sense_id:, distractor_sense_id:,
      )
      miss.miss_count += 1
      miss.update!(last_missed_at: Time.current)
    end
  end

  def chosen_sense_ids(text)
    glosses = text.split(";").map(&:squish)
    list_memberships.where(senses: { gloss: glosses })
      .distinct.pluck("senses.entry_id")
      .select { |entry_id| list_back(entry_id) == text }
      .flat_map { |entry_id| memberships_of(entry_id).pluck(:sense_id) }
  end
end
