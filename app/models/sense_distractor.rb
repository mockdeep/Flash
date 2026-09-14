# frozen_string_literal: true

# One user's record of choosing distractor_sense's card when asked for
# sense's. Rows accrete from misses and bias that user's future option
# lists toward their actual confusions.
class SenseDistractor < ApplicationRecord
  belongs_to :user
  belongs_to :sense
  belongs_to :distractor_sense, class_name: "Sense"

  attribute(:miss_count, :integer, default: 0)

  validates :distractor_sense_id, uniqueness: { scope: [:user_id, :sense_id] }
end
