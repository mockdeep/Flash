# frozen_string_literal: true

# One entry as a language deck studies it: the list's glosses for the entry
# rejoined as the back, and the owner's skill scores on those senses as the
# streak. Not a row - built from the deck's enumeration - which is what lets
# a deck be a single row over a shared word_list.
class LanguageCard
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
    SkillScore.transaction { scores.each(&:record_correct!) }
    @correct_streak += 1
  end

  # A miss resets the streak; when the chosen answer is given it's also
  # remembered as a distractor for future option lists (the reading stage
  # passes none - a reading miss never records a translation distractor).
  def record_miss!(chosen_answer = nil)
    SkillScore.transaction do
      scores.each(&:record_miss!)
      remember(chosen_answer) if chosen_answer
    end
    @correct_streak = 0
  end

  private

  attr_reader :entry

  def scores
    sense_ids.map do |sense_id|
      SkillScore.find_or_initialize_by(
        user_id: deck.user_id, sense_id:, skill: deck.skill,
      )
    end
  end

  # Every member sense links to every sense the chosen option displayed.
  def remember(text)
    sense_ids.product(deck.sense_ids_shown_as(text)).each do
      |sense_id, distractor_sense_id|
      miss = SenseDistractor.find_or_initialize_by(
        user_id: deck.user_id, sense_id:, distractor_sense_id:,
      )
      miss.miss_count += 1
      miss.update!(last_missed_at: Time.current)
    end
  end

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
