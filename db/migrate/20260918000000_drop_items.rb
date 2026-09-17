# frozen_string_literal: true

# Nothing has read items since 4.5 (docs/compendium.md, 4.6): fronts became
# entries at 4.1, glosses became senses at 4.2, the decoy Back items went at
# 4.4, and the reading cards that anchored the rest went at 4.5. Every card
# row left is a flat one that never carried an item, so the column and the
# table go together.
class DropItems < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      remove_reference :cards, :item, index: true, foreign_key: true
      drop_table :items
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
