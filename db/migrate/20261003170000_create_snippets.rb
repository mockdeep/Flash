# frozen_string_literal: true

# A snippet is a source text feeding one word_list (docs/compendium.md, Texts
# feed word lists). Its sentences keep the text as written alongside the
# tokens the content pipeline cut it into, each pointing at the sense it
# landed on, so the original can be read back word by word.
class CreateSnippets < ActiveRecord::Migration[8.1]
  def change
    create_snippets
    create_snippet_sentences
  end

  private

  def create_snippets
    create_table :snippets do |t|
      t.references :word_list, **owned(:word_lists)
      t.string :title, null: false
      t.string :author
      t.text :body, null: false
      t.timestamps
    end
  end

  def create_snippet_sentences
    create_table :snippet_sentences do |t|
      t.references :snippet, **owned(:snippets), index: false
      t.integer :position, null: false
      t.text :body, null: false
      t.jsonb :tokens, null: false, default: []
      t.timestamps
      t.index [:snippet_id, :position], unique: true
    end
  end

  def owned(table)
    { null: false, foreign_key: { to_table: table, on_delete: :cascade } }
  end
end
