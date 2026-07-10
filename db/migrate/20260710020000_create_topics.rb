# frozen_string_literal: true

# Topics are user-created containers grouping data_sets (see NOTES.md).
# Deleting a topic releases its data_sets rather than deleting content.
class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table(:topics) do |t|
      t.string(:name, null: false)
      t.references(:user, null: false, foreign_key: { on_delete: :cascade })
      t.timestamps
      t.index([:user_id, :name], unique: true)
    end

    add_reference(:data_sets, :topic, foreign_key: { on_delete: :nullify })
  end
end
