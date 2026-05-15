# frozen_string_literal: true

class AddOrderedToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :ordered, :boolean, default: false, null: false
  end
end
