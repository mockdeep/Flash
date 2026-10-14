# frozen_string_literal: true

# The decks page groups decks by language and deck type on its own, so
# topics went.
class DropTopics < ActiveRecord::Migration[8.1]
  def change
    # The app ignored the column already.
    safety_assured do
      remove_reference :decks,
                       :topic,
                       foreign_key: { on_delete: :nullify },
                       index: true
    end

    drop_table :topics do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
      t.index [:user_id, :name], unique: true
    end
  end
end
