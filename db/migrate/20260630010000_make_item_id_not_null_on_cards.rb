# frozen_string_literal: true

class MakeItemIdNotNullOnCards < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      # No production cards lack an item; clear out any orphans elsewhere.
      execute("DELETE FROM cards WHERE item_id IS NULL")
      change_column_null(:cards, :item_id, false)
      remove_foreign_key(:cards, :items)
      add_foreign_key(:cards, :items, on_delete: :cascade)
    end
  end

  def down
    safety_assured do
      change_column_null(:cards, :item_id, true)
      remove_foreign_key(:cards, :items)
      add_foreign_key(:cards, :items, on_delete: :nullify)
    end
  end
end
