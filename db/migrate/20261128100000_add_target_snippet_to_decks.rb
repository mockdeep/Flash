# frozen_string_literal: true

# A target date can cover a source's chapters up to one of them instead of
# the whole deck. A chapter a push deletes leaves the target on the whole
# deck.
class AddTargetSnippetToDecks < ActiveRecord::Migration[8.1]
  def change
    add_reference(
      :decks,
      :target_snippet,
      foreign_key: { to_table: :snippets, on_delete: :nullify },
    )
  end
end
