# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table(:items) do |t|
      t.references(
        :data_set,
        null: false,
        index: false,
        foreign_key: { on_delete: :cascade },
      )
      t.string(:side, null: false)
      t.string(:text, null: false)
      t.string(:reading)
      t.string(:example)
      t.string(:category)
      t.timestamps
    end

    add_index(:items, [:data_set_id, :side, :text], unique: true)
  end
end
