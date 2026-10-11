# frozen_string_literal: true

# A user an admin has let read a snippet its license keeps from sharing.
# Production-only, like other user data: it never travels in a compendium
# snapshot, and goes with the snippet when a push deletes it.
class CreateSnippetReaders < ActiveRecord::Migration[8.1]
  def change
    create_table :snippet_readers do |t|
      t.references :snippet, **owned(:snippets), index: false
      t.references :user, **owned(:users)
      t.timestamps
      t.index [:snippet_id, :user_id], unique: true
    end
  end

  private

  def owned(table)
    { null: false, foreign_key: { to_table: table, on_delete: :cascade } }
  end
end
