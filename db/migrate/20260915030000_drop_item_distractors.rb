# frozen_string_literal: true

# Misses record to sense_distractors now (docs/compendium.md, 4.4), so the
# item-side pool and the Back items that existed only to be its decoys go.
# Old rows are not carried over: the feature continues, the history does
# not. The local dry run against a production copy removed 7,510 rows and
# 3,170 Back items, none of which anchored a card.
class DropItemDistractors < ActiveRecord::Migration[8.1]
  def up
    drop_table :item_distractors
    safety_assured { execute "DELETE FROM items WHERE side = 'Back'" }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
