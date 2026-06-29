# frozen_string_literal: true

class RemoveNameFromDecks < ActiveRecord::Migration[8.1]
  def up
    safety_assured { remove_column(:decks, :name) }
  end

  def down
    add_column(:decks, :name, :string)
    add_index(:decks, [:user_id, :name], unique: true)
  end
end
