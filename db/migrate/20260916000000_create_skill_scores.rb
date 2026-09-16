# frozen_string_literal: true

# Progress for language decks (docs/compendium.md, 4.5): one row per user,
# sense and skill, so a word's streak is the user's wherever the word is
# studied and survives the deck that taught it. Card counters stay
# authoritative and dual-write here until the read switch at 4.5(b).
class CreateSkillScores < ActiveRecord::Migration[8.1]
  def change
    create_table :skill_scores do |t|
      t.references :user, **owned(:users), index: false
      t.references :sense, **owned(:senses)
      t.string :skill, null: false
      t.integer :correct_count, null: false, default: 0
      t.integer :correct_streak, null: false, default: 0
      t.integer :view_count, null: false, default: 0
      t.timestamps
      t.index [:user_id, :sense_id, :skill], unique: true
    end
  end

  private

  def owned(table)
    { null: false, foreign_key: { to_table: table, on_delete: :cascade } }
  end
end
