# frozen_string_literal: true

# STI base for a set of language study content; LanguageDataSet is the only
# subclass since Basic and Music moved to flat deck-owned cards. Becomes the
# compendium's word_lists table when the language machinery evolves.
class DataSet < ApplicationRecord
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :decks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
