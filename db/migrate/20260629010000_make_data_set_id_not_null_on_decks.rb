# frozen_string_literal: true

class MakeDataSetIdNotNullOnDecks < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      # No production decks lack a data set; clear out any orphans elsewhere.
      execute("DELETE FROM decks WHERE data_set_id IS NULL")
      change_column_null(:decks, :data_set_id, false)
      remove_foreign_key(:decks, :data_sets)
      add_foreign_key(:decks, :data_sets, on_delete: :cascade)
    end
  end

  def down
    safety_assured do
      change_column_null(:decks, :data_set_id, true)
      remove_foreign_key(:decks, :data_sets)
      add_foreign_key(:decks, :data_sets, on_delete: :nullify)
    end
  end
end
