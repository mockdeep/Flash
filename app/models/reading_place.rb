# frozen_string_literal: true

# Where a user left off reading a source: the token the Read-tab page they
# last opened starts at.
class ReadingPlace < ApplicationRecord
  belongs_to :user
  belongs_to :source
  belongs_to :snippet_sentence

  validates :user, :source, :snippet_sentence, :token_index, presence: true
  validates :user_id, uniqueness: { scope: :source_id }

  def self.record!(user:, source:, start:)
    place = find_or_initialize_by(user:, source:)
    place.update!(
      snippet_sentence_id: start.sentence_id,
      token_index: start.index,
    )
  end
end
