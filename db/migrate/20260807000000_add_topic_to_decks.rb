# frozen_string_literal: true

# Topic assignment moves from data_sets onto decks (each deck is assigned
# individually, matching the deck-page UX). Backfills from the data_set so
# existing assignments carry over; data_sets.topic_id is ignored by the app
# from this deploy and dropped in a follow-up migration.
class AddTopicToDecks < ActiveRecord::Migration[8.1]
  def change
    add_reference(:decks, :topic, foreign_key: { on_delete: :nullify })

    reversible do |dir|
      dir.up do
        # Single small-table UPDATE; no batching needed at this data size.
        safety_assured do
          execute(<<~SQL.squish)
            UPDATE decks
            SET topic_id = data_sets.topic_id
            FROM data_sets
            WHERE decks.data_set_id = data_sets.id
              AND data_sets.topic_id IS NOT NULL
          SQL
        end
      end
    end
  end
end
