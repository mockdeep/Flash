# frozen_string_literal: true

# A word is its text plus its reading, so homographs (two readings of one
# written form) can share a word_list without the front marks that the old
# index forced. NULLs stay
# equal: Back items carry no reading, and add_distractor relies on the index
# to dedup them by text.
class AddReadingToItemsUniqueIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index(
      :items,
      [:word_list_id, :side, :text, :reading],
      unique: true,
      nulls_not_distinct: true,
      algorithm: :concurrently,
    )
    remove_index(
      :items,
      [:word_list_id, :side, :text],
      unique: true,
      algorithm: :concurrently,
    )
  end
end
