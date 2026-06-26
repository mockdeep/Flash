# frozen_string_literal: true

class AddItemToCards < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :cards,
      :item,
      null: true,
      foreign_key: { on_delete: :nullify },
    )
  end
end
