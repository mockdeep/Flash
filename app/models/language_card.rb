# frozen_string_literal: true

# One entry as a language deck studies it: the list's glosses for the entry
# rejoined as the back, and the owner's skill scores on those senses as the
# streak. Not a row - built from the deck's enumeration - which is what lets
# a deck be a single row over a shared word_list.
class LanguageCard
  CORRECT = <<~SQL.squish
    correct_count = skill_scores.correct_count + 1,
    correct_streak = skill_scores.correct_streak + 1,
    view_count = skill_scores.view_count + 1,
    updated_at = excluded.updated_at
  SQL
  MISS = <<~SQL.squish
    correct_streak = 0,
    view_count = skill_scores.view_count + 1,
    updated_at = excluded.updated_at
  SQL
  REMEMBER = <<~SQL.squish
    miss_count = sense_distractors.miss_count + 1,
    last_missed_at = excluded.last_missed_at,
    updated_at = excluded.updated_at
  SQL

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
    score(CORRECT, correct_count: 1, correct_streak: 1)
    @correct_streak += 1
  end

  # A miss resets the streak; when the chosen answer is given it's also
  # remembered as a distractor for future option lists (the reading stage
  # passes none - a reading miss never records a translation distractor).
  def record_miss!(chosen_answer = nil)
    shown_as = chosen_answer ? deck.sense_ids_shown_as(chosen_answer) : []
    SkillScore.transaction do
      score(MISS)
      remember(shown_as)
    end
    @correct_streak = 0
  end

  private

  attr_reader :entry

  # One statement for every member sense, however many there are: a new
  # score starts from the given counters, an existing one moves by the SQL.
  def score(on_duplicate, **counters)
    SkillScore.upsert_all(
      score_rows(**counters),
      unique_by: [:user_id, :sense_id, :skill],
      on_duplicate: Arel.sql(on_duplicate),
    )
  end

  def score_rows(**counters)
    sense_ids.map do |sense_id|
      {
        user_id: deck.user_id,
        sense_id:,
        skill: deck.skill,
        view_count: 1,
        **counters,
      }
    end
  end

  # Every member sense links to every sense the chosen option displayed.
  def remember(distractor_sense_ids)
    SenseDistractor.upsert_all(
      miss_rows(distractor_sense_ids),
      unique_by: [:user_id, :sense_id, :distractor_sense_id],
      on_duplicate: Arel.sql(REMEMBER),
    )
  end

  def miss_rows(distractor_sense_ids)
    sense_ids.product(distractor_sense_ids).map do
      |sense_id, distractor_sense_id|
      {
        user_id: deck.user_id,
        sense_id:,
        distractor_sense_id:,
        miss_count: 1,
        last_missed_at: Time.current,
      }
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
