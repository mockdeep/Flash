# frozen_string_literal: true

# A source (an article, a book, a drawer of scraps) holds what its snippets
# share: their title, author, link and license. Each snippet becomes one of
# its sections, under a heading. The new snippet columns stay nullable until
# every snippet has been given its source.
class CreateSources < ActiveRecord::Migration[8.1]
  def change
    create_table :sources do |t|
      t.references :word_list,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   index: { unique: true }
      t.string :title, null: false
      t.string :author
      t.string :source_url
      t.string :license, null: false, default: "all_rights_reserved"
      t.timestamps
    end

    add_reference :snippets, :source, foreign_key: { on_delete: :cascade }
    add_column :snippets, :heading, :string
  end
end
