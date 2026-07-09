# frozen_string_literal: true

class AddLanguageToDataSets < ActiveRecord::Migration[8.0]
  def up
    add_column :data_sets, :language, :string

    safety_assured do
      execute(<<~SQL.squish)
        UPDATE data_sets SET language = 'zh'
        WHERE id IN (
          SELECT DISTINCT data_set_id FROM items
          WHERE text ~ '[一-鿿㐀-䶿]'
        )
      SQL
    end
  end

  def down
    remove_column :data_sets, :language
  end
end
