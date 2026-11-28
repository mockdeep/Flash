# frozen_string_literal: true

module ReadingMap
  # A list on the map: its ring, its angle there, the learner's heat, and
  # their decks over it, with those still short of today's goal.
  Node = Data.define(:word_list, :ring, :angle, :heat, :decks, :unmet_decks)

  class Node
    def initialize(decks: [], unmet_decks: [], **) = super

    def started? = decks.any?

    def unmet? = unmet_decks.any?

    # Every goal met today. A deck with no goal has none to meet, so a
    # node whose decks all have no goal never counts.
    def met? = !unmet? && decks.any? { !it.no_goal? }

    # The deck Continue opens: the first short of today's goal, else the
    # one last studied, else the first.
    def continue_deck
      unmet_decks.first || decks.select(&:last_studied_at)
        .max_by(&:last_studied_at) || decks.first
    end
  end
end
