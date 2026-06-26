# frozen_string_literal: true

class ItemDistractor < ApplicationRecord
  belongs_to :item
  belongs_to :distractor_item, class_name: "Item"
end
