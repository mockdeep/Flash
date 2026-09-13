# frozen_string_literal: true

module WordLists
  # Phase 4's second rung (docs/compendium.md, 4.2). Every pairing becomes a
  # sense under the front's entry, selected into the front's word_list by a
  # membership whose position follows pairing order, so a card's glosses
  # rejoin in the same order they show today. A front's example sentence
  # attaches to every sense it pairs to.
  #
  # Idempotent: rows that already exist are skipped. Lives only until its
  # production run is verified.
  #
  #   WordLists::ExtractSenses.call              # writes nothing
  #   WordLists::ExtractSenses.call(dry_run: false)
  module ExtractSenses
    extend self

    # `unmapped_pairings` and `back_mismatches` must both be 0 after a run:
    # every pairing has a membership, and every front's glosses rejoin from
    # senses byte-identical to today's. `multi_example_senses` counts senses
    # that collected different sentences from different lists.
    Report = Data.define(
      :senses,
      :memberships,
      :examples,
      :unmapped_pairings,
      :back_mismatches,
      :multi_example_senses,
    )

    PAIRED = <<~SQL.squish
      FROM pairings p
      JOIN items f ON f.id = p.item_id
      JOIN items b ON b.id = p.paired_item_id
    SQL

    SENSES = <<~SQL.squish
      INSERT INTO senses (entry_id, gloss, created_at, updated_at)
      SELECT DISTINCT f.entry_id, b.text, NOW(), NOW() #{PAIRED}
      ON CONFLICT DO NOTHING
    SQL

    MEMBERSHIPS = <<~SQL.squish
      INSERT INTO sense_memberships
        (sense_id, word_list_id, position, category, created_at, updated_at)
      SELECT s.id, f.word_list_id,
        ROW_NUMBER() OVER (PARTITION BY f.word_list_id ORDER BY p.id),
        f.category, NOW(), NOW()
      #{PAIRED}
      JOIN senses s ON s.entry_id = f.entry_id AND s.gloss = b.text
      ON CONFLICT DO NOTHING
    SQL

    EXAMPLES = <<~SQL.squish
      INSERT INTO sense_examples
        (sense_id, sentence, translation, created_at, updated_at)
      SELECT DISTINCT s.id, f.example, f.paired_example, NOW(), NOW()
      #{PAIRED}
      JOIN senses s ON s.entry_id = f.entry_id AND s.gloss = b.text
      WHERE f.example IS NOT NULL AND f.example <> ''
      ON CONFLICT DO NOTHING
    SQL

    UNMAPPED = <<~SQL.squish
      SELECT COUNT(*) #{PAIRED}
      WHERE NOT EXISTS (
        SELECT 1 FROM senses s
        JOIN sense_memberships m ON m.sense_id = s.id
        WHERE s.entry_id = f.entry_id AND s.gloss = b.text
          AND m.word_list_id = f.word_list_id
      )
    SQL

    # Today's back per front (glosses in pairing order) against the back its
    # list's senses rejoin to (glosses in membership order).
    MISMATCHES = <<~SQL.squish
      WITH today AS (
        SELECT f.word_list_id, f.entry_id,
          STRING_AGG(b.text, '; ' ORDER BY p.id) AS back
        #{PAIRED}
        GROUP BY f.id
      ), rejoined AS (
        SELECT m.word_list_id, s.entry_id,
          STRING_AGG(s.gloss, '; ' ORDER BY m.position) AS back
        FROM sense_memberships m JOIN senses s ON s.id = m.sense_id
        GROUP BY m.word_list_id, s.entry_id
      )
      SELECT COUNT(*) FROM today
      LEFT JOIN rejoined ON rejoined.word_list_id = today.word_list_id
        AND rejoined.entry_id = today.entry_id
      WHERE rejoined.back IS DISTINCT FROM today.back
    SQL

    def call(dry_run: true)
      report = nil
      ActiveRecord::Base.transaction do
        report = perform
        raise ActiveRecord::Rollback if dry_run
      end
      report
    end

    private

    # The three inserts run in order before the checks that follow them.
    def perform
      Report.new(
        senses: written(SENSES),
        memberships: written(MEMBERSHIPS),
        examples: written(EXAMPLES),
        unmapped_pairings: count(UNMAPPED),
        back_mismatches: count(MISMATCHES),
        multi_example_senses:,
      )
    end

    # Runs an INSERT and returns how many rows it wrote.
    def written(sql)
      ActiveRecord::Base.connection.execute(sql).cmd_tuples
    end

    def count(sql)
      ActiveRecord::Base.connection.select_value(sql)
    end

    def multi_example_senses
      SenseExample.group(:sense_id).having("COUNT(*) > 1").count.size
    end
  end
end
