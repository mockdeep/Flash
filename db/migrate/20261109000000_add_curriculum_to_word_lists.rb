# frozen_string_literal: true

class AddCurriculumToWordLists < ActiveRecord::Migration[8.1]
  def change
    add_column :word_lists, :curriculum, :boolean, null: false, default: false

    reversible do |direction|
      direction.up do
        safety_assured { execute(<<~SQL.squish) }
          UPDATE word_lists SET curriculum = true
          WHERE name LIKE 'Mandarin HSK3.0 Level _'
        SQL
      end
    end
  end
end
