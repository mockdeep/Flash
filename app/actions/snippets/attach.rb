# frozen_string_literal: true

module Snippets
  # Appends the senses a snippet and its source's front matter use to its
  # word_list, in the order they meet them, after the senses the list
  # already holds.
  module Attach
    def self.call(snippet)
      memberships = snippet.word_list.sense_memberships
      sentences = snippet.sentences_with_front_matter
      sense_ids = sentences.flat_map(&:tokens).pluck("sense_id").compact
      position = memberships.maximum(:position) || 0

      (sense_ids.uniq - memberships.pluck(:sense_id)).each do |sense_id|
        memberships.create!(sense_id:, position: position += 1)
      end
    end
  end
end
