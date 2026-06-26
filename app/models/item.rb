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
end
