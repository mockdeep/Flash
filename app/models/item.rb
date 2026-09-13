# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :word_list
  belongs_to :entry
  has_many :cards, dependent: :destroy

  has_many :pairings, dependent: :destroy
  has_many :paired_items, through: :pairings, source: :paired_item

  has_many :item_distractors, dependent: :destroy
  has_many :distractors, through: :item_distractors, source: :distractor_item

  validates :side, presence: true
  validates :text, presence: true
  validates :entry, presence: true, if: :front?

  def front? = side == WordLists::Projection::FRONT

  # Paired Back-item texts in authored order (pairing id), forming the glosses
  # of this Front item. Uses loaded associations so callers can preload.
  def glosses
    pairings.sort_by(&:id).map { |pairing| pairing.paired_item.text }
  end
end
