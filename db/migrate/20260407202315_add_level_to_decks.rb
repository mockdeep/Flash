# frozen_string_literal: true

class AddLevelToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :level, :integer

    Deck.find_each do |deck|
      min_streak = deck.cards.minimum(:correct_streak) || 0
      deck.update!(level: min_streak + 1)
    end

    change_column_null :decks, :level, false
  end
end
