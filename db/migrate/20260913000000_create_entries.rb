# frozen_string_literal: true

# The compendium's first table (docs/compendium.md, 4.1): one row per word
# per language, identified by headword + reading. NULLs stay equal in the
# unique index, since every language but Mandarin carries no reading and
# would otherwise duplicate freely. Front items point at their entry; the
# column is nullable until the backfill has run.
class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.string :language, null: false
      t.string :headword, null: false
      t.string :reading
      t.timestamps
      t.index(
        [:language, :headword, :reading],
        unique: true,
        nulls_not_distinct: true,
      )
    end
    add_reference :items, :entry, foreign_key: true
  end
end
