# frozen_string_literal: true

# Every deck over a source covers the whole source now, its snippet decks
# merged into one, and the app ignores the column already.
class RemoveSnippetIdFromDecks < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_reference :decks, :snippet, foreign_key: true, index: true
    end
  end
end
