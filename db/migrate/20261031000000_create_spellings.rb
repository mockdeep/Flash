# frozen_string_literal: true

class CreateSpellings < ActiveRecord::Migration[8.1]
  def change
    create_table :spellings do |t|
      t.references :entry, null: false, foreign_key: { on_delete: :cascade }
      t.string :text, null: false
      t.timestamps

      t.index [:entry_id, :text], unique: true
      t.index :text
    end
  end
end
