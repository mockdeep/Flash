# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :data_set
  has_many :cards, dependent: :nullify

  has_many :pairings, dependent: :destroy
  has_many :paired_items, through: :pairings, source: :paired_item

  # The reverse direction: pairings in which this item is the paired_item, so a
  # Back item can reach the Front items it answers for (DB cascade handles the
  # cleanup; see the FK on paired_item_id).
  has_many :inverse_pairings,
           class_name: "Pairing",
           foreign_key: :paired_item_id,
           inverse_of: :paired_item,
           dependent: :destroy

  has_many :item_distractors, dependent: :destroy
  has_many :distractors, through: :item_distractors, source: :distractor_item

  validates :side, presence: true
  validates :text, presence: true

  # Paired Back-item texts in authored order (pairing id), forming the glosses
  # of this Front item. Uses loaded associations so callers can preload.
  def glosses
    pairings.sort_by(&:id).map { |pairing| pairing.paired_item.text }
  end

  # The mirror of #glosses for a reverse deck: texts of the items paired TO this
  # one (this item as the prompt), in authored order.
  def reverse_glosses
    inverse_pairings.sort_by(&:id).map { |pairing| pairing.item.text }
  end
end
