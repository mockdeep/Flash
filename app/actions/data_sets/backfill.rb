# frozen_string_literal: true

# One-time catch-up that mirrors every existing text deck into its data_set.
# Reuses the idempotent DataSets::Projection.rebuild, so it is safe to re-run
# and also repairs any partially-projected data_set left by a single-card write
# before the deck was backfilled.
module DataSets
  module Backfill
    def self.call
      count = 0
      TextDeck.find_each do |deck|
        DataSets::Projection.rebuild(deck)
        count += 1
      end
      count
    end
  end
end
