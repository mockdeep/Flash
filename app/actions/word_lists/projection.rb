# frozen_string_literal: true

# The last of the language write path. Language content is frozen ahead of the
# compendium migration: nothing creates or reshapes items any more, so all
# that remains is giving a deck its progress anchors over content that
# already exists.
module WordLists
  module Projection
    extend self

    # One card per item in the deck's word_list. Runs when a deck is created
    # over existing content - a catalog copy shares the source's word_list by
    # reference, so only these anchors are the copier's own.
    def build_cards(deck, limit: nil)
      items(deck, limit).each do |item|
        deck.card_type.constantize.create!(deck:, item:)
      end
      # Cards were created outside the loaded association above.
      deck.cards.reset
    end

    private

    # An item the deck already anchors is passed over, so filling a
    # part-built deck cannot double up. Anchored ids exclude nulls: a NULL
    # inside the subquery would make `where.not` match nothing at all.
    def items(deck, limit)
      scope = deck.word_list.items
        .where.not(id: deck.cards.where.not(item_id: nil).select(:item_id))
      limit ? scope.order(:id).limit(limit) : scope
    end
  end
end
