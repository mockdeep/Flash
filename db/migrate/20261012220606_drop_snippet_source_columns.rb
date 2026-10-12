# frozen_string_literal: true

# Sources took over a snippet's title, author, link, license, list and
# readers, and every snippet now has one.
class DropSnippetSourceColumns < ActiveRecord::Migration[8.1]
  def change
    # Snippets is a small table, and the app ignored these columns already.
    safety_assured do
      change_table :snippets, bulk: true do |t|
        t.remove :title, type: :string
        t.remove :author, type: :string
        t.remove :source_url, type: :string
        t.remove :license,
                 type: :string,
                 null: false,
                 default: "all_rights_reserved"
        t.remove_references :word_list,
                            foreign_key: { on_delete: :cascade },
                            index: true
        t.change_null :source_id, false
      end
    end

    drop_table :snippet_readers do |t|
      t.references :snippet,
                   null: false,
                   foreign_key: { on_delete: :cascade },
                   index: false
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
      t.index [:snippet_id, :user_id], unique: true
    end
  end
end
