# frozen_string_literal: true

# Language decks now always generate their options from siblings, so the
# pool column no longer applies to them; the 12 still marked preset from
# their upload days are set to category so the data stops saying something
# the code no longer honors. preset stays a Basic-deck setting.
class NormalizeLanguageDeckDistractorPools < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute <<~SQL.squish
        UPDATE decks SET distractor_pool = 'category'
        WHERE word_list_id IS NOT NULL AND distractor_pool = 'preset'
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
