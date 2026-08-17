# frozen_string_literal: true

class Pairing < ApplicationRecord
  belongs_to :item, inverse_of: :pairings
  belongs_to :paired_item, class_name: "Item"
end
