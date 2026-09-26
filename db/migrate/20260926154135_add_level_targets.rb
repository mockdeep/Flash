# frozen_string_literal: true

# A deck's goal is either a hand-set number of cards per session or worked
# out from a level target ("finish level N by date"). The daily goal worked
# out from a target is saved on the day's row, since study_days keeps only
# the current batch's count and can't rebuild it later.
class AddLevelTargets < ActiveRecord::Migration[8.1]
  def change
    # New columns only, so there's nothing for strong_migrations to catch.
    safety_assured do
      change_table :decks, bulk: true do |t|
        t.string :goal_mode, null: false, default: "session"
        t.integer :target_level
        t.date :target_date
      end
    end
    add_column :study_days, :goal, :integer
  end
end
