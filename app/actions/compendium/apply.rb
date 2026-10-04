# frozen_string_literal: true

module Compendium
  # Makes a database's compendium match a snapshot, by id: rows only in the
  # snapshot are added, rows that differ are updated, and rows missing from it
  # are deleted. Additions and updates go parents first and deletions
  # children first, so foreign keys hold throughout. A list's owner is never
  # changed; a new list goes to `owner_id`. It runs no transaction of its
  # own: the caller decides whether to commit.
  module Apply
    Report =
      Data.define(:changes, :losses) do
        def to_s
          lines = changes.map { |table, counts| "#{table}: #{summary(counts)}" }
          lines += losses.map { |table, count| "#{table} lost: #{count}" }
          lines.join("\n")
        end

        private

        def summary(counts)
          counts.map { |kind, count| "#{count} #{kind}" }.join(", ")
        end
      end

    def self.call(connection, snapshot, owner_id:)
      TABLES.each { |table| Staging.create(connection, snapshot, table) }
      losses = losses(connection)
      changes = TABLES.index_with { |table| add(connection, table, owner_id) }
      TABLES.reverse_each do |table|
        changes[table][:deleted] = delete(connection, table)
        Staging.drop(connection, table)
      end

      Report.new(changes:, losses:)
    end

    # Updates before inserts, so a row renamed away from a value frees it for
    # a new row that takes it.
    def self.add(connection, table, owner_id)
      updated = update(connection, table)

      { added: insert(connection, table, owner_id), updated: }
    end

    def self.update(connection, table)
      columns = Compendium.columns(connection, table) - ["id"]
      source = Compendium.quote(connection, columns, prefix: "s.")
      target = Compendium.quote(connection, columns, prefix: "t.")

      connection.exec(<<~SQL.squish).cmd_tuples
        UPDATE #{table} t
        SET (#{Compendium.quote(connection, columns)}) = ROW(#{source})
        FROM #{Staging.name(table)} s
        WHERE t.id = s.id AND ROW(#{target}) IS DISTINCT FROM ROW(#{source})
      SQL
    end

    def self.insert(connection, table, owner_id)
      owner = OWNER_COLUMN[table]
      columns = [Compendium.column_list(connection, table), owner]
      source = Compendium.column_list(connection, table, prefix: "s.")
      values = [source, ("$1" if owner)]

      connection.exec_params(<<~SQL.squish, owner ? [owner_id] : []).cmd_tuples
        INSERT INTO #{table} (#{columns.compact.join(", ")})
        SELECT #{values.compact.join(", ")} FROM #{Staging.name(table)} s
        WHERE NOT EXISTS (SELECT 1 FROM #{table} t WHERE t.id = s.id)
      SQL
    end

    def self.delete(connection, table)
      connection.exec(<<~SQL.squish).cmd_tuples
        DELETE FROM #{table} t WHERE NOT EXISTS
        (SELECT 1 FROM #{Staging.name(table)} s WHERE s.id = t.id)
      SQL
    end

    # Learner data that goes with the senses it points at. Counted before
    # anything changes, so a dry run can say what a push would cost.
    def self.losses(connection)
      gone = "SELECT id FROM senses EXCEPT " \
             "SELECT id FROM #{Staging.name("senses")}"
      distracted = "sense_id IN (#{gone}) OR distractor_sense_id IN (#{gone})"
      {
        "skill_scores" =>
          count(connection, "skill_scores", "sense_id IN (#{gone})"),
        "sense_distractors" =>
          count(connection, "sense_distractors", distracted),
      }
    end

    def self.count(connection, table, condition)
      sql = "SELECT COUNT(*) FROM #{table} WHERE #{condition}"

      Integer(connection.exec(sql).getvalue(0, 0))
    end
  end
end
