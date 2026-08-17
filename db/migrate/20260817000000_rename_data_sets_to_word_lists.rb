# frozen_string_literal: true

# data_sets become the compendium's word_lists. Basic and Music left this table
# in phase 2 and language content froze in phase 3, so LanguageDataSet is the
# only type left and the STI column goes with the rename.
class RenameDataSetsToWordLists < ActiveRecord::Migration[8.1]
  # strong_migrations wants the expand/contract dance for a table rename. The
  # brief window where a running process still names data_sets is accepted
  # here: the migration and the code that reads the new names deploy together,
  # and language content is frozen, so nothing writes during it.
  def change
    safety_assured do
      rename_table(:data_sets, :word_lists)
      rename_column(:decks, :data_set_id, :word_list_id)
      rename_column(:items, :data_set_id, :word_list_id)
      remove_column(:word_lists, :type, :string, null: false)
    end
  end
end
