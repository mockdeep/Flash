# frozen_string_literal: true

# Per-user miss records for language decks (docs/compendium.md, 4.4): a
# user chose one sense's card over another's. Keyed to senses rather than
# items, so a confusion learned in one deck follows the user to every list
# holding both words, and to the user rather than the list, so one user's
# misses stop shaping every user's options on a shared list.
class CreateSenseDistractors < ActiveRecord::Migration[8.1]
  def change
    create_table :sense_distractors do |t|
      t.references :user, **owned(:users), index: false
      t.references :sense, **owned(:senses), index: false
      t.references :distractor_sense, **owned(:senses)
      t.integer :miss_count, null: false
      t.datetime :last_missed_at, null: false
      t.timestamps
      t.index(
        [:user_id, :sense_id, :distractor_sense_id],
        unique: true,
        name: "index_sense_distractors_on_user_sense_and_distractor",
      )
    end
  end

  private

  def owned(table)
    { null: false, foreign_key: { to_table: table, on_delete: :cascade } }
  end
end
