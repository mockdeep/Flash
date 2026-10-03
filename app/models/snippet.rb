# frozen_string_literal: true

# A source text used for generating a word_list.
class Snippet < ApplicationRecord
  belongs_to :word_list
  has_many :sentences,
           -> { order(:position) },
           class_name: "SnippetSentence",
           dependent: :delete_all,
           inverse_of: :snippet

  validates :word_list, :title, :body, presence: true
end
