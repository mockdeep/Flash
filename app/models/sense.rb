# frozen_string_literal: true

# One meaning of an entry, and the unit a learner studies: distractors key
# to it, and progress will. Word_lists select senses through memberships.
class Sense < ApplicationRecord
  belongs_to :entry
  has_many :sense_memberships, dependent: :destroy
  has_many :word_lists, through: :sense_memberships
  has_many :sense_examples, dependent: :destroy
  has_many :sense_distractors, dependent: :delete_all

  validates :gloss, presence: true, uniqueness: { scope: :entry_id }
end
