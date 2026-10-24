# frozen_string_literal: true

# When the refiner last reviewed an entry, so each run picks up the ones
# it has gone longest without. Syncs with the rest of the compendium.
class AddReviewedAtToEntries < ActiveRecord::Migration[8.1]
  def change
    add_column(:entries, :reviewed_at, :datetime)
  end
end
