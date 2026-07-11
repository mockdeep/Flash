# frozen_string_literal: true

# Card classes renamed to match the deck renames (see NOTES.md): forward
# cards split by their deck's type into Reading and Basic, and the reverse
# card becomes Writing.
class RenameCardTypes < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE cards SET type = CASE
          WHEN type = 'ReverseTextCard' THEN 'WritingCard'
          WHEN type = 'TextCard' AND EXISTS (
            SELECT 1 FROM decks
            WHERE decks.id = cards.deck_id
              AND decks.type = 'ReadingDeck'
          ) THEN 'ReadingCard'
          WHEN type = 'TextCard' THEN 'BasicCard'
          ELSE type
        END
      SQL
    end
  end

  def down
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE cards SET type = CASE
          WHEN type = 'WritingCard' THEN 'ReverseTextCard'
          WHEN type IN ('ReadingCard', 'BasicCard') THEN 'TextCard'
          ELSE type
        END
      SQL
    end
  end
end
