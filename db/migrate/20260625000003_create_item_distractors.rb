# frozen_string_literal: true

class CreateItemDistractors < ActiveRecord::Migration[8.1]
  def change
    create_table(:item_distractors) do |t|
      t.references(
        :item,
        null: false,
        index: false,
        foreign_key: { on_delete: :cascade },
      )
      t.references(
        :distractor_item,
        null: false,
        foreign_key: { to_table: :items, on_delete: :cascade },
      )
      t.timestamps
    end

    add_index(:item_distractors, [:item_id, :distractor_item_id], unique: true)
  end
end
