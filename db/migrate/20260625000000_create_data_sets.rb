# frozen_string_literal: true

class CreateDataSets < ActiveRecord::Migration[8.1]
  def change
    create_table(:data_sets) do |t|
      t.references(
        :user,
        null: false,
        index: false,
        foreign_key: { on_delete: :cascade },
      )
      t.string(:name, null: false)
      t.timestamps
    end

    add_index(:data_sets, [:user_id, :name], unique: true)
  end
end
