# frozen_string_literal: true

# Writing (reverse) decks are retired: the WritingDeck and WritingCard classes
# are gone, so any surviving row would raise SubclassNotFound on load.
# Production was already cleared by hand; this makes the deploy safe against
# any database that still holds one.
class DropWritingDecks < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute("DELETE FROM cards WHERE type = 'WritingCard'")
      execute("DELETE FROM decks WHERE type = 'WritingDeck'")
    end
  end

  def down
    raise(ActiveRecord::IrreversibleMigration)
  end
end
