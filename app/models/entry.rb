# frozen_string_literal: true

# One word in one language: a headword plus its reading, so two readings of
# the same written form (hai2 / huan2 for the same character) are two
# entries. The compendium's canonical record; word_lists select over it
# through their items.
class Entry < ApplicationRecord
  has_many :items, dependent: :restrict_with_exception
  has_many :senses, dependent: :restrict_with_exception

  validates :language, presence: true, inclusion: { in: WordList::LANGUAGES.keys }
  validates :headword, presence: true
  validates :headword, uniqueness: { scope: [:language, :reading] }
end
