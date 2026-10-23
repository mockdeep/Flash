# frozen_string_literal: true

# A source an admin has listed in the catalog.
class SourceListing < ApplicationRecord
  belongs_to :source

  validates :source, presence: true
end
