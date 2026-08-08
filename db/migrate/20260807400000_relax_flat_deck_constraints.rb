# frozen_string_literal: true

# Flat-card decks (Basic, Music) are created without a data_set and their
# cards without an item from this deploy on, so both FKs become nullable.
# The partial unique index takes over the front-uniqueness guarantee that
# the items table's (data_set_id, side, text) index used to provide.
class RelaxFlatDeckConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_null(:decks, :data_set_id, true)
    change_column_null(:cards, :item_id, true)
    add_index(
      :cards, [:deck_id, :front], unique: true, where: "front IS NOT NULL"
    )
  end
end
