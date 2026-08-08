# frozen_string_literal: true

# Decks own their user directly (every family) and, for the flat-card
# families, their name; language decks keep reading their name through the
# data_set until the compendium rename. Groundwork for Basic/Music decks
# dropping their data_set entirely.
class AddOwnershipToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column(:decks, :name, :string)
    add_reference(:decks, :user, foreign_key: { on_delete: :cascade })
    add_index(
      :decks, [:user_id, :name], unique: true, where: "name IS NOT NULL"
    )

    reversible { |dir| dir.up { backfill } }

    change_column_null(:decks, :user_id, false)
  end

  private

  def backfill
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE decks
        SET user_id = data_sets.user_id
        FROM data_sets
        WHERE decks.data_set_id = data_sets.id
      SQL

      execute(<<~SQL.squish)
        UPDATE decks
        SET name = data_sets.name
        FROM data_sets
        WHERE decks.data_set_id = data_sets.id
          AND decks.type IN ('BasicDeck', 'MusicDeck')
      SQL
    end
  end
end
