# frozen_string_literal: true

# Re-runs the flat-card backfill immediately before reads switch to the card
# columns: Basic/Music writes between the backfill deploy and the dual-write
# deploy left stale rows, and this sweep (a full idempotent re-stamp plus a
# distractor reconcile) closes that gap.
class ResyncFlatCardContent < ActiveRecord::Migration[8.1]
  def up
    restamp_content
    restamp_backs
    prune_stale_distractors
    insert_missing_distractors
  end

  # Data-only top-up; nothing to reverse.
  def down; end

  private

  def restamp_content
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE cards
        SET front = items.text,
            back = NULL,
            category = items.category,
            reading = items.reading,
            example_front = items.example,
            example_back = items.paired_example
        FROM items
        WHERE cards.item_id = items.id
          AND cards.type IN ('BasicCard', 'MusicCard')
      SQL
    end
  end

  def restamp_backs
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE cards
        SET back = agg.backs
        FROM (
          SELECT pairings.item_id,
                 string_agg(items.text, '; ' ORDER BY pairings.id) AS backs
          FROM pairings
          JOIN items ON items.id = pairings.paired_item_id
          GROUP BY pairings.item_id
        ) agg
        WHERE cards.item_id = agg.item_id
          AND cards.type IN ('BasicCard', 'MusicCard')
      SQL
    end
  end

  def prune_stale_distractors
    safety_assured do
      execute(<<~SQL.squish)
        DELETE FROM card_distractors
        USING cards
        WHERE cards.id = card_distractors.card_id
          AND cards.type IN ('BasicCard', 'MusicCard')
          AND NOT EXISTS (
            SELECT 1
            FROM item_distractors
            JOIN items ON items.id = item_distractors.distractor_item_id
            WHERE item_distractors.item_id = cards.item_id
              AND items.text = card_distractors.text
          )
      SQL
    end
  end

  def insert_missing_distractors
    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO card_distractors (card_id, text, created_at, updated_at)
        SELECT cards.id, items.text, NOW(), NOW()
        FROM cards
        JOIN item_distractors ON item_distractors.item_id = cards.item_id
        JOIN items ON items.id = item_distractors.distractor_item_id
        WHERE cards.type IN ('BasicCard', 'MusicCard')
        ON CONFLICT (card_id, text) DO NOTHING
      SQL
    end
  end
end
