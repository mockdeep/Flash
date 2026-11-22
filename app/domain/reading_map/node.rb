# frozen_string_literal: true

module ReadingMap
  # A list on the map: its ring, its angle there, the learner's heat, and
  # their decks over it (a source's, one per section they have started),
  # with whether any of those is still short of today's goal.
  Node = Data.define(:word_list, :ring, :angle, :heat, :decks, :unmet)

  class Node
    NEVER = Time.zone.at(0)

    def initialize(decks: [], unmet: false, **) = super

    def started? = decks.any?

    def unmet? = unmet

    # Every goal met today. A deck with no goal has none to meet, so a
    # node whose decks all have no goal never counts.
    def met? = !unmet && decks.any? { !it.no_goal? }

    def last_studied = decks.filter_map(&:last_studied_at).max || NEVER
  end
end
