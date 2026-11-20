# frozen_string_literal: true

class AddMapColumnsToWordLists < ActiveRecord::Migration[8.1]
  def change
    change_table :word_lists, bulk: true do |t|
      t.string :visibility, null: false, default: "private"
      t.integer :level
      t.float :angle
    end
  end
end
