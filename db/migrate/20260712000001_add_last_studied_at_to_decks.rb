# frozen_string_literal: true

class AddLastStudiedAtToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :last_studied_at, :datetime
  end
end
