# frozen_string_literal: true

# A word_list can no longer be destroyed while any deck references it
# (docs/compendium.md, Open questions). The model enforces it with
# restrict_with_exception; this makes the database agree, so a raw delete
# gets the same answer instead of cascading through every user's deck.
class RestrictWordListDeleteWhileReferenced < ActiveRecord::Migration[8.1]
  def up
    safety_assured do
      remove_foreign_key(:decks, :word_lists)
      add_foreign_key(:decks, :word_lists)
    end
  end

  def down
    safety_assured do
      remove_foreign_key(:decks, :word_lists)
      add_foreign_key(:decks, :word_lists, on_delete: :cascade)
    end
  end
end
