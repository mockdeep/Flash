# frozen_string_literal: true

module ReadingMap
  # A list on the map: its ring, its angle there, the learner's heat, their
  # deck over it once they have started it, and whether that deck is still
  # short of today's goal.
  Node = Data.define(:word_list, :ring, :angle, :heat, :deck, :unmet)

  class Node
    def initialize(deck: nil, unmet: false, **) = super

    def started? = deck.present?

    def unmet? = unmet

    # Its goal met today. A deck with no goal has none to meet, so it never
    # counts.
    def met? = started? && !unmet? && !deck.no_goal?
  end
end
