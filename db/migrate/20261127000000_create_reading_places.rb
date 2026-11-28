# frozen_string_literal: true

# Where a reader left off in a source: the token a Read-tab page starts at.
# Production-only user data, like source_readers.
class CreateReadingPlaces < ActiveRecord::Migration[8.1]
  def change
    create_table :reading_places do |t|
      t.references :user, **owned(:users), index: false
      t.references :source, **owned(:sources)
      t.references :snippet_sentence, **owned(:snippet_sentences)
      t.integer :token_index, null: false
      t.timestamps
      t.index [:user_id, :source_id], unique: true
    end
  end

  private

  def owned(table)
    { null: false, foreign_key: { to_table: table, on_delete: :cascade } }
  end
end
