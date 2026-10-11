# frozen_string_literal: true

# A user an admin has let read a snippet, whatever its license.
class SnippetReader < ApplicationRecord
  belongs_to :snippet
  belongs_to :user

  validates :user_id, uniqueness: { scope: :snippet_id }
end
