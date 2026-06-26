# frozen_string_literal: true

class Pairing < ApplicationRecord
  belongs_to :item
  belongs_to :paired_item, class_name: "Item"

  validates :item_id, uniqueness: { scope: :paired_item_id }
end
