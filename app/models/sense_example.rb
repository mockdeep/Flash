# frozen_string_literal: true

# A teaching sentence for a sense, shown on card reveal. Rows come only from
# trusted sources, so every one is shareable.
class SenseExample < ApplicationRecord
  belongs_to :sense

  validates :sentence, presence: true, uniqueness: { scope: :sense_id }
end
