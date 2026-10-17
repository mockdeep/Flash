# frozen_string_literal: true

# A Portuguese noun studies with its definite article ("a casa"), which
# tells its gender and number. Like a reading, it can tell two entries of
# one headword apart (o capital "money", a capital "capital city"), so it
# joins the unique index.
class AddArticleToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :entries, :article, :string
    remove_index(
      :entries,
      [:language, :headword, :reading],
      unique: true,
      nulls_not_distinct: true,
    )
    add_index(
      :entries,
      [:language, :headword, :reading, :article],
      unique: true,
      nulls_not_distinct: true,
    )
  end
end
