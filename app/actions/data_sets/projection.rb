# frozen_string_literal: true

# Builds a deck's data_set (items, pairings, item_distractors) and its thin
# cards from content rows. A "row" is a hash of card content
# ({ front:, back:, category:, distractors:, reading:, example_front:,
# example_back:, source_card_id? }) -- the same shape a CSV row produces.
# Items are the source of truth; cards are item_id + progress.
#
# Language content is being frozen ahead of the compendium migration, so this
# writer is shrinking: per-card editing, deletion, and re-import are gone,
# leaving first ingest, reverse-deck card generation, and miss-recorded
# decoys. Nothing mutates an existing data_set's items any more, which is why
# sibling-deck reconciliation went with them.
module DataSets
  module Projection
    extend self

    FRONT = "Front"
    BACK = "Back"

    # Fresh build for a copied deck (Catalog::CopyDeck, the last caller now
    # that language upload is gone): fill the data_set from the rows and
    # create one thin card per row.
    def build(deck, rows)
      data_set = reset_data_set(deck)
      item_ids = insert_data(data_set, rows)
      insert_cards(deck, rows, item_ids)
    end

    # Record a language card's wrong-guess distractor as an item reference.
    # The decoy lives on the side opposite the prompt (a reverse miss is a
    # Front-side decoy), so it stays an unpaired item and never spawns a card.
    # Flat-card misses never reach here; they write card_distractors directly.
    def add_distractor(card, text)
      prompt = card.item
      decoy_side = prompt.side == FRONT ? BACK : FRONT
      decoy = prompt.data_set.items.find_or_create_by!(side: decoy_side, text:)
      ItemDistractor.find_or_create_by!(item: prompt, distractor_item: decoy)
    end

    # Populate a freshly created reverse deck: one card per paired item on its
    # anchor side. Content is frozen, so there is never anything to reconcile
    # afterwards - this runs once, on a deck with no cards yet.
    def build_anchor_cards(deck)
      anchor_items(deck).each { |item| create_anchor_card(deck, item) }
      # Cards were created outside the loaded association above.
      deck.cards.reset
    end

    private

    def reset_data_set(deck)
      data_set = deck.data_set
      data_set.items.delete_all
      data_set
    end

    def insert_data(data_set, rows)
      return {} if rows.empty?

      item_ids = insert_items(data_set, rows)
      insert_pairings(rows, item_ids)
      insert_distractors(rows, item_ids)
      item_ids
    end

    def insert_items(data_set, rows)
      result = Item.insert_all(
        item_rows(data_set, rows),
        returning: ["id", "side", "text"],
      )
      result.rows.to_h { |id, side, text| [[side, text], id] }
    end

    def item_rows(data_set, rows)
      items = {}
      rows.each do |row|
        items[[FRONT, row[:front]]] = front_row(data_set, row)
        back_texts(row).each do |text|
          items[[BACK, text]] ||= back_row(data_set, text)
        end
      end
      items.values
    end

    def back_texts(row)
      glosses(row) + terms(row[:distractors])
    end

    def front_row(data_set, row)
      {
        data_set_id: data_set.id,
        side: FRONT,
        text: row[:front],
        **front_attributes(row),
      }
    end

    def back_row(data_set, text)
      {
        data_set_id: data_set.id,
        side: BACK,
        text:,
        category: nil,
        reading: nil,
        example: nil,
        paired_example: nil,
      }
    end

    def insert_pairings(rows, item_ids)
      pairings =
        rows.flat_map do |row|
          front_id = item_ids.fetch([FRONT, row[:front]])
          glosses(row).map do |gloss|
            { item_id: front_id, paired_item_id: item_ids.fetch([BACK, gloss]) }
          end
        end
      Pairing.insert_all(pairings) if pairings.any?
    end

    def insert_distractors(rows, item_ids)
      distractors =
        rows.flat_map do |row|
          front_id = item_ids.fetch([FRONT, row[:front]])
          terms(row[:distractors]).map do |text|
            decoy_id = item_ids.fetch([BACK, text])
            { item_id: front_id, distractor_item_id: decoy_id }
          end
        end
      ItemDistractor.insert_all(distractors) if distractors.any?
    end

    def insert_cards(deck, rows, item_ids)
      return if rows.empty?

      Card.insert_all(rows.map { |row| card_row(deck, row, item_ids) })
    end

    def card_row(deck, row, item_ids)
      {
        deck_id: deck.id,
        type: deck.card_type,
        item_id: item_ids.fetch([FRONT, row[:front]]),
        source_card_id: row[:source_card_id],
      }
    end

    # Items on the deck's anchor side that participate in a pairing - a card is
    # generated only for paired items (a distractor-only item gets none).
    def anchor_items(deck)
      deck.data_set.items
        .where(side: deck.anchor_side, id: pairing_anchor_ids(deck))
    end

    def pairing_anchor_ids(deck)
      Pairing.select(deck.anchor_pairing_column)
    end

    def create_anchor_card(deck, item)
      deck.card_type.constantize.create!(deck:, item:)
    end

    def front_attributes(content)
      {
        category: content[:category],
        reading: content[:reading],
        example: content[:example_front],
        paired_example: content[:example_back],
      }
    end

    def glosses(content)
      terms(content[:back].to_s.split(";"))
    end

    def terms(values)
      Array(values).map { |value| value.to_s.squish }.compact_blank.uniq
    end
  end
end
