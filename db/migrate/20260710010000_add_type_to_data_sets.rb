# frozen_string_literal: true

class AddTypeToDataSets < ActiveRecord::Migration[8.1]
  def up
    add_column(:data_sets, :type, :string)

    safety_assured do
      execute(<<~SQL.squish)
        UPDATE data_sets SET type = CASE
          WHEN EXISTS (
            SELECT 1 FROM decks
            WHERE decks.data_set_id = data_sets.id
              AND decks.type = 'MusicDeck'
          ) THEN 'MusicDataSet'
          WHEN language IS NOT NULL THEN 'LanguageDataSet'
          ELSE 'BasicDataSet'
        END
      SQL

      change_column_null(:data_sets, :type, false)
    end
  end

  def down
    remove_column(:data_sets, :type)
  end
end
