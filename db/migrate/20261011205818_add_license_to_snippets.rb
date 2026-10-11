# frozen_string_literal: true

# A snippet's license decides who else may read it, so it defaults to the
# one that shares with nobody.
class AddLicenseToSnippets < ActiveRecord::Migration[8.1]
  def change
    # Two new columns, one with a constant default: no rewrite, no backfill.
    safety_assured do
      change_table :snippets, bulk: true do |t|
        t.string :license, null: false, default: "all_rights_reserved"
        t.string :source_url
      end
    end
  end
end
