# frozen_string_literal: true

# A language deck over a source's list can study one of its snippets
# instead of the whole list.
class AddSnippetToDecks < ActiveRecord::Migration[8.1]
  def change
    add_reference(:decks, :snippet, foreign_key: true)
  end
end
