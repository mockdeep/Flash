# frozen_string_literal: true

# Topic assignment moved onto decks (backfilled there); the app has ignored
# this column since that deploy.
class DropTopicFromDataSets < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_reference(:data_sets, :topic) }
  end
end
