# frozen_string_literal: true

class AddDistractorPoolToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :distractor_pool, :string
    reversible do |dir|
      dir.up do
        safety_assured do
          execute("UPDATE decks SET distractor_pool = 'category'")
        end
      end
    end
    change_column_null :decks, :distractor_pool, false
  end
end
