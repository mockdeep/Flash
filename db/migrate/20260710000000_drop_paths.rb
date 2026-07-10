# frozen_string_literal: true

# Paths (ordered deck sequences) never got built beyond this schema; the
# Topics design supersedes it. See NOTES.md.
class DropPaths < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      remove_column(:decks, :path_id)
      remove_column(:decks, :path_position)
      drop_table(:paths)
    end
  end

  def down
    create_table(:paths) do |t|
      t.string(:name, null: false)
      t.references(:user, null: false, foreign_key: true)
      t.timestamps
      t.index([:user_id, :name], unique: true)
    end
    add_reference(:decks, :path, foreign_key: true)
    add_column(:decks, :path_position, :integer)
    add_index(:decks, [:path_id, :path_position], unique: true)
  end
end
