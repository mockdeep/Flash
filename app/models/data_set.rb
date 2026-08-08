# frozen_string_literal: true

# STI base for a set of study content. Subclasses (Language, Music, Basic)
# declare their own rules; the base class is never instantiated.
class DataSet < ApplicationRecord
  # Topic assignment moved to decks; the column drops in a follow-up migration.
  self.ignored_columns += ["topic_id"]

  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :decks, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }

  # The deck classes that can be built over this data_set; each subclass
  # declares its own.
  def deck_classes = []
end
