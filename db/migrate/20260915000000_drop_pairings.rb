# frozen_string_literal: true

# Senses and memberships replaced pairings as the source of a card's glosses
# (docs/compendium.md, 4.2), and nothing reads pairings any more. The Back
# items that existed only to be paired go with them; the ones still
# referenced as miss-recorded decoys stay until 4.4 replaces that table.
class DropPairings < ActiveRecord::Migration[8.1]
  def up
    drop_table :pairings
    # Deletes nothing a card or a decoy reference points at; the local dry
    # run against a production copy removed 25,990 of 29,160 Back items.
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM items
        WHERE side = 'Back' AND NOT EXISTS (
          SELECT 1 FROM item_distractors d WHERE d.distractor_item_id = items.id
        )
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
