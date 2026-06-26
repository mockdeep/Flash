# frozen_string_literal: true

namespace(:data_sets) do
  desc("Rebuild every text deck's data_set from its cards")
  task(backfill: :environment) do
    puts("Backfilled #{DataSets::Backfill.call} text deck(s).")
  end
end
