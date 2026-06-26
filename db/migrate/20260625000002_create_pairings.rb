# frozen_string_literal: true

class CreatePairings < ActiveRecord::Migration[8.1]
  def change
    create_table(:pairings) do |t|
      t.references(
        :item,
        null: false,
        index: false,
        foreign_key: { on_delete: :cascade },
      )
      t.references(
        :paired_item,
        null: false,
        foreign_key: { to_table: :items, on_delete: :cascade },
      )
      t.timestamps
    end

    add_index(:pairings, [:item_id, :paired_item_id], unique: true)
  end
end
