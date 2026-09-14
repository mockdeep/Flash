# frozen_string_literal: true

# The last of the language write path. Language content is frozen ahead of the
# compendium migration: nothing creates or reshapes items any more, so all
# that remains is giving a deck its progress anchors over content that
# already exists, and recording a miss as a decoy.
module WordLists
  module Projection
    extend self

    FRONT = "Front"
    BACK = "Back"

    # One card per Front item in the deck's word_list. Runs when a deck is
    # created over existing content - a catalog copy shares the source's
    # word_list by reference, so only these anchors are the copier's own.
    def build_cards(deck, limit: nil)
      fronts(deck, limit).each do |item|
        deck.card_type.constantize.create!(deck:, item:)
      end
      # Cards were created outside the loaded association above.
      deck.cards.reset
    end

    # Record a language card's wrong-guess distractor as an item reference.
    # Every language card anchors a Front item, so the decoy is a Back item,
    # which never spawns a card. Flat-card misses never reach here; they
    # write card_distractors directly.
    def add_distractor(card, text)
      prompt = card.item
      decoy = prompt.word_list.items.find_or_create_by!(side: BACK, text:)
      ItemDistractor.find_or_create_by!(item: prompt, distractor_item: decoy)
    end

    private

    # Only Front items get a card; a decoy Back item gets none, and an item
    # the deck already anchors is passed over, so filling a part-built deck
    # cannot double up. Anchored ids exclude nulls: a NULL inside the
    # subquery would make `where.not` match nothing at all.
    def fronts(deck, limit)
      scope = deck.word_list.items.where(side: FRONT)
        .where.not(id: deck.cards.where.not(item_id: nil).select(:item_id))
      limit ? scope.order(:id).limit(limit) : scope
    end
  end
end
