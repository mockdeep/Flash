# frozen_string_literal: true

# Moves the study session counter out of the Rails session and into the
# database, one row per deck per day, so daily goals can be worked out from
# what was actually studied.
class CreateStudyDays < ActiveRecord::Migration[8.1]
  def change
    create_table :study_days do |t|
      t.references :deck,
                   null: false,
                   index: false,
                   foreign_key: { on_delete: :cascade }
      t.date :studied_on, null: false
      t.integer :completed_count, null: false, default: 0
      t.timestamps
      t.index [:deck_id, :studied_on], unique: true
    end
  end
end
