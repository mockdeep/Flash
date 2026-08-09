# frozen_string_literal: true

# The flat-card families are fully off the item layer: legacy Basic/Music
# decks shed their data_sets, and the orphaned data_sets delete along with
# their items (cascade). FK order matters - cards -> items and
# decks -> data_sets both cascade on delete, so the flat FKs are nulled
# BEFORE the delete or the cascade would take the cards and decks with it.
class DropFlatDeckDataSets < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE cards SET item_id = NULL
        WHERE type IN ('BasicCard', 'MusicCard')
      SQL
      execute(<<~SQL.squish)
        UPDATE decks SET data_set_id = NULL
        WHERE type IN ('BasicDeck', 'MusicDeck')
      SQL
      execute(<<~SQL.squish)
        DELETE FROM data_sets
        WHERE type IN ('BasicDataSet', 'MusicDataSet')
      SQL
    end
  end

  # Destructive data migration; nothing to reverse.
  def down; end
end
