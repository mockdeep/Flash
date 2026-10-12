# frozen_string_literal: true

# A user an admin has let read a source its license keeps from sharing,
# taking over from letting them read one snippet at a time: a reader of any
# of a source's snippets becomes a reader of the source. Production-only,
# like other user data. Snippets now reach their list through their source,
# so their own word_list_id is no longer written; it and snippet_readers go
# once this is deployed.
class CreateSourceReaders < ActiveRecord::Migration[8.1]
  def change
    create_table :source_readers do |t|
      t.references :source, **owned(:sources), index: false
      t.references :user, **owned(:users)
      t.timestamps
      t.index [:source_id, :user_id], unique: true
    end

    reversible { |direction| direction.up { copy_snippet_readers } }
    change_column_null :snippets, :word_list_id, true
  end

  private

  def owned(table)
    { null: false, foreign_key: { to_table: table, on_delete: :cascade } }
  end

  def copy_snippet_readers
    safety_assured { execute(<<~SQL.squish) }
      INSERT INTO source_readers (source_id, user_id, created_at, updated_at)
      SELECT snippets.source_id, snippet_readers.user_id,
             MIN(snippet_readers.created_at), MIN(snippet_readers.created_at)
      FROM snippet_readers
      JOIN snippets ON snippets.id = snippet_readers.snippet_id
      WHERE snippets.source_id IS NOT NULL
      GROUP BY snippets.source_id, snippet_readers.user_id
    SQL
  end
end
