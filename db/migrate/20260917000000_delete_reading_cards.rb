# frozen_string_literal: true

# Language decks read the compendium and score to skill_scores now
# (docs/compendium.md, 4.5), so the per-deck reading card rows go. Their
# counters were carried onto the scores by the 4.5(a) backfill, and
# nothing has read or written them since 4.5(c) deployed. The local run
# against a production copy removed 36,534 rows. `cards.item_id` stays
# until items go at 4.6.
class DeleteReadingCards < ActiveRecord::Migration[8.1]
  def up
    safety_assured { execute "DELETE FROM cards WHERE type = 'ReadingCard'" }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
