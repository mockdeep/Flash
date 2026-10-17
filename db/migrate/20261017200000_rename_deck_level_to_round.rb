# frozen_string_literal: true

# A deck's "level" read too much like a list's own level (HSK 3), so a pass
# through the deck is now a round. Run in one deploy: a request in the gap
# between the migration and the new code may fail.
class RenameDeckLevelToRound < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      rename_column :decks, :level, :round
      rename_column :decks, :target_level, :target_round
    end
  end
end
