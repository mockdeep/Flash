# frozen_string_literal: true

# The catalog suggestion flow is retired: the compendium removes its premise
# (users select over canonical senses rather than authoring card content), and
# it was one of the language write paths that must close before the migration.
class DropCardSuggestions < ActiveRecord::Migration[8.1]
  def up
    drop_table(:card_suggestions)
  end

  def down
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
