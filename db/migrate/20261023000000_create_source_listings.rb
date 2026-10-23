# frozen_string_literal: true

# A source an admin has listed in the catalog. Production-only, like
# source_readers: publishing decides who sees the content, so it isn't part
# of the compendium and never syncs.
class CreateSourceListings < ActiveRecord::Migration[8.1]
  def change
    create_table :source_listings do |t|
      t.references :source,
                   null: false,
                   index: { unique: true },
                   foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
