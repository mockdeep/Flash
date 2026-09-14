# frozen_string_literal: true

# A wrong-answer option owned directly by a Basic card (uploaded preset lists
# and remembered study misses). The flat-card counterpart of SenseDistractor.
class CardDistractor < ApplicationRecord
  belongs_to :card

  validates :text, presence: true
end
