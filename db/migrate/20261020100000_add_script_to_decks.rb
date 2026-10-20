# frozen_string_literal: true

# A language deck studies its words in one script; a Mandarin deck in
# traditional splits a card whose meanings are spelled apart. The default
# only fills the existing rows: new decks get theirs from the model.
class AddScriptToDecks < ActiveRecord::Migration[8.1]
  def change
    add_column(:decks, :script, :string, null: false, default: "simplified")
    change_column_default(:decks, :script, from: "simplified", to: nil)
  end
end
