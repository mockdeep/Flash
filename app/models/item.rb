# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :word_list
  belongs_to :entry

  validates :side, presence: true
  validates :text, presence: true
  validates :entry, presence: true
end
