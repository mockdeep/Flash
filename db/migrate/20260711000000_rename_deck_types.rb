# frozen_string_literal: true

# Deck classes renamed to match their UI representation (see NOTES.md):
# forward decks split by their data_set's type into Reading (language) and
# Basic, and the reverse deck becomes Writing.
class RenameDeckTypes < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE decks SET type = CASE
          WHEN type = 'ReverseTextDeck' THEN 'WritingDeck'
          WHEN type = 'TextDeck' AND EXISTS (
            SELECT 1 FROM data_sets
            WHERE data_sets.id = decks.data_set_id
              AND data_sets.type = 'LanguageDataSet'
          ) THEN 'ReadingDeck'
          WHEN type = 'TextDeck' THEN 'BasicDeck'
          ELSE type
        END
      SQL
    end
  end

  def down
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE decks SET type = CASE
          WHEN type = 'WritingDeck' THEN 'ReverseTextDeck'
          WHEN type IN ('ReadingDeck', 'BasicDeck') THEN 'TextDeck'
          ELSE type
        END
      SQL
    end
  end
end
