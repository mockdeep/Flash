# frozen_string_literal: true

class RemoveUserFromDecks < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      remove_reference(:decks, :user, foreign_key: true, index: false)
    end
  end

  def down
    add_reference(:decks, :user, foreign_key: true, index: false)
  end
end
