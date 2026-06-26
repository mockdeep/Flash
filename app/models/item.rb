# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :data_set
  has_many :cards, dependent: :nullify

  has_many :pairings, dependent: :destroy
  has_many :paired_items, through: :pairings, source: :paired_item

  has_many :item_distractors, dependent: :destroy
  has_many :distractors, through: :item_distractors, source: :distractor_item

  validates :side, presence: true
  validates :text, presence: true, uniqueness: { scope: [:data_set_id, :side] }

  # Paired Back-item texts in authored order (pairing id), forming the glosses
  # of this Front item. Uses loaded associations so callers can preload.
  def glosses
    pairings.sort_by(&:id).map { |pairing| pairing.paired_item.text }
  end
end
