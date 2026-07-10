# frozen_string_literal: true

# A user-created container grouping data_sets (e.g. "Mandarin", "Music") so
# related decks collect together on the index.
class Topic < ApplicationRecord
  belongs_to :user, optional: false
  has_many :data_sets, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
