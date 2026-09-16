# frozen_string_literal: true

# One entry as a language deck studies it: the list's glosses for the entry
# rejoined as the back, and the owner's skill scores on those senses as the
# streak. Not a row - built from the deck's enumeration - which is what lets
# a deck be a single row over a shared word_list. Until 4.5(c) every write
# still goes through the deck's card row, which dual-writes to the scores.
class WordCard
  attr_reader :deck, :correct_streak

  def initialize(deck, entry)
    @deck = deck
    @entry = entry
    @correct_streak = entry.correct_streak
  end

  delegate :id, :reading, :back, :category, :sense_ids, to: :entry

  def front = entry.headword

  def done? = correct_streak >= deck.level

  def homograph? = deck.homograph?(self)

  def example_front = example&.sentence
  def example_back = example&.translation

  # Entries sharing a back display once.
  def distractors = deck.backs_of(decoy_entry_ids).uniq

  # Credit fans out to every member sense, so the streak moves in lockstep.
  def record_correct!
    anchor.record_correct!
    @correct_streak += 1
  end

  def record_miss!(chosen_answer = nil)
    anchor.record_miss!(chosen_answer)
    @correct_streak = 0
  end

  private

  attr_reader :entry

  def anchor = deck.cards.joins(:item).find_by!(items: { entry_id: id })

  def decoy_entry_ids
    SenseDistractor.where(user_id: deck.user_id, sense_id: sense_ids)
      .joins(:distractor_sense).distinct.pluck("senses.entry_id")
  end

  # The earliest sentence any member sense holds; a sense shared between
  # lists can carry one from each.
  def example
    return @example if defined?(@example)

    @example = SenseExample.where(sense_id: sense_ids).order(:id).first
  end
end
