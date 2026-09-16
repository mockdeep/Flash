# frozen_string_literal: true

module WordLists
  # Phase 4's fifth rung, part (a) (docs/compendium.md, 4.5). Every reading
  # card's counters seed a skill score for its deck's owner on each sense
  # the list selects for the card's entry. Where two of a user's cards hold
  # one sense, each counter keeps the greater value; the same rule merges
  # with scores the dual-write has already written, so the run is
  # idempotent and safe while decks are being studied.
  #
  # Lives only until its production run is verified.
  #
  #   WordLists::BackfillSkillScores.call              # writes nothing
  #   WordLists::BackfillSkillScores.call(dry_run: false)
  module BackfillSkillScores
    extend self

    # `orphan_cards` and `short_scores` must both be 0 after a run: every
    # card has a member sense to score, and no score sits below a card it
    # was seeded from. `disagreeing_senses` counts (user, sense) pairs whose
    # cards carried different counters, resolved by the max.
    Report =
      Data.define(:scores, :disagreeing_senses, :orphan_cards, :short_scores)

    # Flat cards carry no item, so the join leaves only language cards.
    MEMBERS = <<~SQL.squish
      FROM cards c
      JOIN decks d ON d.id = c.deck_id
      JOIN items i ON i.id = c.item_id
      JOIN sense_memberships m ON m.word_list_id = i.word_list_id
      JOIN senses s ON s.id = m.sense_id AND s.entry_id = i.entry_id
    SQL

    SCORES = <<~SQL.squish
      INSERT INTO skill_scores (user_id, sense_id, skill,
        correct_count, correct_streak, view_count, created_at, updated_at)
      SELECT d.user_id, s.id, 'reading',
        MAX(c.correct_count), MAX(c.correct_streak), MAX(c.view_count),
        NOW(), NOW()
      #{MEMBERS}
      GROUP BY d.user_id, s.id
      ON CONFLICT (user_id, sense_id, skill) DO UPDATE SET
        correct_count =
          GREATEST(skill_scores.correct_count, EXCLUDED.correct_count),
        correct_streak =
          GREATEST(skill_scores.correct_streak, EXCLUDED.correct_streak),
        view_count = GREATEST(skill_scores.view_count, EXCLUDED.view_count),
        updated_at = NOW()
    SQL

    DISAGREEING = <<~SQL.squish
      SELECT COUNT(*) FROM (
        SELECT 1 #{MEMBERS}
        GROUP BY d.user_id, s.id
        HAVING COUNT(DISTINCT
          (c.correct_count, c.correct_streak, c.view_count)) > 1
      ) pairs
    SQL

    ORPHANS = <<~SQL.squish
      SELECT COUNT(*) FROM cards c
      JOIN items i ON i.id = c.item_id
      WHERE NOT EXISTS (
        SELECT 1 FROM sense_memberships m
        JOIN senses s ON s.id = m.sense_id
        WHERE m.word_list_id = i.word_list_id AND s.entry_id = i.entry_id
      )
    SQL

    SHORT = <<~SQL.squish
      SELECT COUNT(DISTINCT c.id) #{MEMBERS}
      LEFT JOIN skill_scores k ON k.user_id = d.user_id
        AND k.sense_id = s.id AND k.skill = 'reading'
      WHERE k.id IS NULL
        OR k.correct_count < c.correct_count
        OR k.correct_streak < c.correct_streak
        OR k.view_count < c.view_count
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

    def perform
      Report.new(
        scores: written(SCORES),
        disagreeing_senses: count(DISAGREEING),
        orphan_cards: count(ORPHANS),
        short_scores: count(SHORT),
      )
    end

    # Runs the INSERT and returns how many rows it wrote or updated.
    def written(sql)
      ActiveRecord::Base.connection.execute(sql).cmd_tuples
    end

    def count(sql)
      ActiveRecord::Base.connection.select_value(sql)
    end
  end
end
