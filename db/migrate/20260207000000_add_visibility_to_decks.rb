# frozen_string_literal: true

class AddVisibilityToDecks < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      add_column :decks, :visibility, :string, null: false, default: "private"
    end
  end
end
