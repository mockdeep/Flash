# frozen_string_literal: true

class AddIndexOnDecksVisibility < ActiveRecord::Migration[8.1]
  def change
    add_index :decks, :visibility
  end
end
