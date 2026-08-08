# frozen_string_literal: true

# Flat-card pass groundwork: Basic and Music cards will own their content
# directly instead of reading through data_set items. Adds the content
# columns (filled only for those families) and the card_distractors table
# mirroring item_distractors, then backfills both from the item layer.
# Reads still go through items; the switch is a later deploy.
class AddContentToCards < ActiveRecord::Migration[8.1]
  def change
    add_content_columns
    create_distractors_table
    reversible do |dir|
      dir.up do
        backfill_content
        backfill_backs
        backfill_distractors
      end
    end
  end

  private

  def add_content_columns
    safety_assured do
      change_table(:cards, bulk: true) do |t|
        t.string(:front)
        t.string(:back)
        t.string(:category)
        t.string(:reading)
        t.string(:example_front)
        t.string(:example_back)
      end
    end
  end

  def create_distractors_table
    create_table(:card_distractors) do |t|
      t.references(
        :card, null: false, foreign_key: { on_delete: :cascade }, index: false
      )
      t.string(:text, null: false)
      t.timestamps
      t.index([:card_id, :text], unique: true)
    end
  end

  def backfill_content
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE cards
        SET front = items.text,
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

  def backfill_backs
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

  def backfill_distractors
    safety_assured do
      execute(<<~SQL.squish)
        INSERT INTO card_distractors (card_id, text, created_at, updated_at)
        SELECT cards.id, items.text, NOW(), NOW()
        FROM cards
        JOIN item_distractors ON item_distractors.item_id = cards.item_id
        JOIN items ON items.id = item_distractors.distractor_item_id
        WHERE cards.type IN ('BasicCard', 'MusicCard')
      SQL
    end
  end
end
