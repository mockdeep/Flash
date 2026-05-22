# frozen_string_literal: true

class AddSourceCardIdToCards < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :cards,
      :source_card,
      foreign_key: { to_table: :cards, on_delete: :nullify },
      null: true,
      index: true,
    )
  end
end
