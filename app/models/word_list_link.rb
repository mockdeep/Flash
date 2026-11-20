# frozen_string_literal: true

# A line on the reading map between two word lists that share words, with
# how strongly they do. A pair is stored once, the lower list id first.
class WordListLink < ApplicationRecord
  belongs_to :word_list
  belongs_to :linked_word_list, class_name: "WordList"

  validates :word_list, :linked_word_list, :strength, presence: true
  validates :linked_word_list_id, uniqueness: { scope: :word_list_id }
  validates :linked_word_list_id,
            comparison: { greater_than: :word_list_id },
            if: :word_list_id
end
