# frozen_string_literal: true

module ReadingMap
  # The lists a learner has started in one language, from their decks
  # there, and which comes next: among those with a deck short of today's
  # goal, the one on the innermost ring, then the most recently studied,
  # then the first by name. The map's next node and the milestone's Next
  # Deck both ask here, so they agree.
  class Started
    NEVER = Time.zone.at(0)

    def initialize(decks:, language:)
      @decks = decks
      @rings = Rings.new(language)
    end

    # The learner's decks over a list.
    def decks(list_id) = by_list.fetch(list_id, [])

    # Those short of today's goal as Next Deck counts it: a deck waiting
    # for tomorrow isn't.
    def unmet_decks(list_id)
      @unmet_decks ||= {}
      @unmet_decks[list_id] ||= decks(list_id).select { unmet?(it) }
    end

    # The deck Next Deck opens: the next list's first unmet one, or none
    # once every goal is met.
    def next_deck
      in_order.lazy.filter_map { unmet_decks(it.id).first }.first
    end

    # The list of the next node; with every goal met, the most recently
    # studied.
    def next_list
      in_order.find { unmet_decks(it.id).any? } || recent_first.first
    end

    private

    def unmet?(deck)
      short_ids.include?(deck.id) && !deck.waiting_for_tomorrow?
    end

    def by_list
      @by_list ||= @decks.where.not(word_list_id: nil)
        .reorder(:id).group_by(&:word_list_id)
    end

    def short_ids = @short_ids ||= @decks.goal_unmet_today.ids.to_set

    # The most recently studied first; those never studied by name.
    def recent_first
      @recent_first ||= oldest_first.reverse
    end

    def oldest_first
      by_name = WordList.where(id: by_list.keys).order(:name, :id)

      by_name.sort_by.with_index do |list, index|
        [last_studied(list), -index]
      end
    end

    # Innermost ring first, each ring's lists the most recent first.
    def in_order
      recent_first.sort_by.with_index do |list, index|
        [@rings.of(list), index]
      end
    end

    def last_studied(list)
      decks(list.id).filter_map(&:last_studied_at).max || NEVER
    end
  end
end
