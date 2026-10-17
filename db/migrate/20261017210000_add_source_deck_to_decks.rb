# frozen_string_literal: true

# A copy of a Basic or Music deck points back at the deck it came from, so
# the catalog can tell a learner they already have it. Copies made before
# this are matched through their cards' source_card_id.
class AddSourceDeckToDecks < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :decks,
      :source_deck,
      foreign_key: { to_table: :decks, on_delete: :nullify },
    )

    reversible { |dir| dir.up { backfill } }
  end

  private

  def backfill
    safety_assured do
      execute(<<~SQL.squish)
        UPDATE decks
        SET source_deck_id = (
          SELECT source_cards.deck_id
          FROM cards
          JOIN cards source_cards ON source_cards.id = cards.source_card_id
          WHERE cards.deck_id = decks.id
          LIMIT 1
        )
        WHERE decks.word_list_id IS NULL
      SQL
    end
  end
end
