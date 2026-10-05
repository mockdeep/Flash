# frozen_string_literal: true

module Snippets
  # Appends the senses a snippet uses to its word_list, in the order the
  # snippet meets them, after the senses the list already holds.
  module Attach
    def self.call(snippet)
      memberships = snippet.word_list.sense_memberships
      sense_ids = snippet.sentences.flat_map(&:tokens).pluck("sense_id").compact
      position = memberships.maximum(:position) || 0

      (sense_ids.uniq - memberships.pluck(:sense_id)).each do |sense_id|
        memberships.create!(sense_id:, position: position += 1)
      end
    end
  end
end
