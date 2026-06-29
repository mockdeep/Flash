# frozen_string_literal: true

class DataSet < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :decks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
