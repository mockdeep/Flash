# frozen_string_literal: true

class AddMapColumnsToWordLists < ActiveRecord::Migration[8.1]
  def change
    # New columns only, so there's nothing for strong_migrations to catch.
    safety_assured do
      change_table :word_lists, bulk: true do |t|
        t.string :visibility, null: false, default: "private"
        t.integer :level
        t.float :angle
      end
    end
  end
end
