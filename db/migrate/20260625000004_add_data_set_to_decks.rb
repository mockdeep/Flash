# frozen_string_literal: true

class AddDataSetToDecks < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :decks,
      :data_set,
      null: true,
      foreign_key: { on_delete: :nullify },
    )
  end
end
