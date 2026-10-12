# frozen_string_literal: true

# A user an admin has let read a source, whatever its license.
class SourceReader < ApplicationRecord
  belongs_to :source
  belongs_to :user

  validates :user_id, uniqueness: { scope: :source_id }
end
