# frozen_string_literal: true

# Round targets gave way to target dates, and the app ignores the column
# already.
class RemoveTargetRoundFromDecks < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :decks, :target_round, :integer }
  end
end
