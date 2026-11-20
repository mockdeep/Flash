# frozen_string_literal: true

class CreateWordListLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :word_list_links do |t|
      t.references :word_list,
                   null: false,
                   index: false,
                   foreign_key: { on_delete: :cascade }
      t.references :linked_word_list,
                   null: false,
                   foreign_key: { to_table: :word_lists, on_delete: :cascade }
      t.float :strength, null: false
      t.timestamps

      t.index [:word_list_id, :linked_word_list_id], unique: true
      t.check_constraint "word_list_id < linked_word_list_id",
                         name: "word_list_links_lower_id_first"
    end
  end
end
