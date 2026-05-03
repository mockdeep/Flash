# frozen_string_literal: true

class AddTypeToDecksAndCards < ActiveRecord::Migration[8.1]
  def change
    add_column :decks, :type, :string
    add_column :cards, :type, :string
    add_index :decks, :type
    add_index :cards, :type

    reversible do |dir|
      dir.up do
        safety_assured do
          execute("UPDATE decks SET type = 'TextDeck'")
          execute("UPDATE cards SET type = 'TextCard'")
        end
      end
    end

    change_column_null :decks, :type, false
    change_column_null :cards, :type, false
  end
end
