# frozen_string_literal: true

class AddStudyGoalToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :study_goal, :integer

    Deck.find_each do |deck|
      deck.update!(study_goal: deck.user.study_goal)
    end

    change_column_null :decks, :study_goal, false
  end
end
