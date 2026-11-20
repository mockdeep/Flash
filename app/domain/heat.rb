# frozen_string_literal: true

# How much of a word list a learner knows, counting the list's entries the
# way a deck's cards do. An entry takes the weakest of the learner's
# reading streaks on the senses the list holds for it, up to FULL: a third
# of a word at a streak of 1, a whole word at 3 or more. Words learned in
# any deck count.
Heat = Data.define(:total, :steps)

class Heat
  FULL = 3
  SCORES_JOIN = <<~SQL.squish
    LEFT JOIN skill_scores ON skill_scores.sense_id = senses.id
      AND skill_scores.user_id = ? AND skill_scores.skill = 'reading'
  SQL
  ENTRY_COLUMNS = <<~SQL.squish
    sense_memberships.word_list_id,
    LEAST(MIN(COALESCE(skill_scores.correct_streak, 0)), #{FULL}) AS streak
  SQL

  # Each list's heat by its id, from one query; a list with no words has
  # none.
  def self.for(user, word_list_ids)
    counts = SenseMembership.from(entries(user, word_list_ids), :entries)
      .group(:word_list_id)
      .pluck(:word_list_id, Arel.sql("COUNT(*)"), Arel.sql("SUM(streak)"))

    counts.to_h { |id, total, steps| [id, new(total:, steps:)] }
  end

  def self.entries(user, word_list_ids)
    scores = SenseMembership.sanitize_sql_array([SCORES_JOIN, user.id])

    SenseMembership.joins(:sense).joins(scores)
      .where(word_list_id: word_list_ids)
      .group(:word_list_id, "senses.entry_id")
      .select(ENTRY_COLUMNS)
  end

  def known = steps.fdiv(FULL)

  # Rounded down, so only a list known in full reads 100.
  def percent = (steps * 100) / (total * FULL)
end
