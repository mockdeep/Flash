# frozen_string_literal: true

class CreateCardSuggestions < ActiveRecord::Migration[8.1]
  def change
    create_table(:card_suggestions) do |t|
      t.references(:card, null: false, foreign_key: { on_delete: :cascade })
      t.references(:user, null: false, foreign_key: { on_delete: :cascade })
      t.string(:front, null: false)
      t.string(:back, null: false)
      t.string(:category, null: false)
      t.string(:state, null: false, default: "pending")
      t.timestamps
    end

    add_index(:card_suggestions, [:card_id, :state])
  end
end
