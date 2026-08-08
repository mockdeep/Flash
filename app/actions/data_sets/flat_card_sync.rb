# frozen_string_literal: true

# Transitional dual-write for the flat-card pass: the projection still owns
# Basic/Music content in items, but after every write the cards' own content
# columns (and mirrored distractors) are stamped from the item layer so they
# stay current until reads switch over. Retires with the Basic/Music item
# layer once those families write cards directly.
module DataSets
  module FlatCardSync
    extend self

    def sync_deck(deck)
      deck.cards.each { |card| sync_card(card) }
    end

    def sync_card(card)
      # A fresh item row, not card.item: the projection re-links items and
      # pairings underneath loaded associations, and reading them here would
      # both see and leave behind stale caches.
      item = Item.find(card.item_id)
      card.update_columns(
        front: item.text,
        back: item.glosses.join(Card::SEPARATOR),
        category: item.category,
        reading: item.reading,
        example_front: item.example,
        example_back: item.paired_example,
      )
      sync_distractors(card, item)
    end

    private

    def sync_distractors(card, item)
      texts = item.distractors.map(&:text)
      card.card_distractors.where.not(text: texts).delete_all
      texts.each { |text| card.card_distractors.find_or_create_by!(text:) }
    end
  end
end
