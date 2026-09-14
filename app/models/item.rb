# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :word_list
  belongs_to :entry
  has_many :cards, dependent: :destroy

  has_many :item_distractors, dependent: :destroy
  has_many :distractors, through: :item_distractors, source: :distractor_item

  validates :side, presence: true
  validates :text, presence: true
  validates :entry, presence: true, if: :front?

  def front? = side == WordLists::Projection::FRONT
end
