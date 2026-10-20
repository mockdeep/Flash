# frozen_string_literal: true

# A Mandarin sense's traditional form, for decks studied in traditional. The
# entry stays keyed by the simplified headword, which merges forms that
# traditional keeps apart, and each traditional spelling of a meaning is
# studied as a sense of its own, so the form joins the unique index.
class AddTraditionalToSenses < ActiveRecord::Migration[8.1]
  def change
    add_column :senses, :traditional, :string
    remove_index :senses, [:entry_id, :gloss], unique: true
    add_index(
      :senses,
      [:entry_id, :gloss, :traditional],
      unique: true,
      nulls_not_distinct: true,
    )
  end
end
