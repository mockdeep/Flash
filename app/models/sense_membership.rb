# frozen_string_literal: true

# A word_list's selection of one sense. Position is the order the sense
# entered the list and orders a card's glosses; category is the list's own
# filing of the word.
class SenseMembership < ApplicationRecord
  belongs_to :sense
  belongs_to :word_list

  validates :position, presence: true
  validates :sense_id, uniqueness: { scope: :word_list_id }
end
