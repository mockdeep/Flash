# frozen_string_literal: true

module ReadingMap
  # What studying one list would gain a learner in another: the other
  # list's words they don't yet know in full that the first list teaches,
  # which is every sense the other holds for the word. Counted in entries,
  # as heat is, and worked out for many pairs of lists in one query.
  Gains = Data.define(:total, :words)

  class Gains
    SQL = <<~SQL.squish
      SELECT pairs.from_id, pairs.to_id, COUNT(*),
        COUNT(*) FILTER (WHERE entries.taught AND entries.streak < :full)
      FROM (VALUES %<pairs>s) AS pairs(from_id, to_id)
      JOIN LATERAL (
        SELECT MIN(COALESCE(skill_scores.correct_streak, 0)) AS streak,
          BOOL_AND(taught.id IS NOT NULL) AS taught
        FROM sense_memberships held
        JOIN senses ON senses.id = held.sense_id
        LEFT JOIN skill_scores ON skill_scores.sense_id = senses.id
          AND skill_scores.user_id = :user_id
          AND skill_scores.skill = 'reading'
        LEFT JOIN sense_memberships taught ON taught.sense_id = held.sense_id
          AND taught.word_list_id = pairs.from_id
        WHERE held.word_list_id = pairs.to_id
        GROUP BY senses.entry_id
      ) entries ON TRUE
      GROUP BY pairs.from_id, pairs.to_id
    SQL

    # Each pair's gains, by the pair: the list studied, then the list
    # gained in. A pair whose second list has no words is left out.
    def self.for(user, pairs)
      return {} if pairs.empty?

      sql = format(SQL, pairs: values(pairs))
      binds = { user_id: user.id, full: Heat::FULL }
      sql = ApplicationRecord.sanitize_sql_array([sql, binds])
      rows = ApplicationRecord.connection.select_rows(sql)

      rows.to_h { |from, to, total, words| [[from, to], new(total:, words:)] }
    end

    # The pairs of ids as rows to select from.
    def self.values(pairs)
      pairs.map { |from, to| "(#{Integer(from)}, #{Integer(to)})" }.join(", ")
    end

    # Rounded down, as heat is.
    def percent = (words * 100) / total
  end
end
