# frozen_string_literal: true

# Builds a deck's data_set (items, pairings, item_distractors) and its thin
# cards from content rows. A "row" is a hash of card content
# ({ front:, back:, category:, distractors:, reading:, example_front:,
# example_back:, source_card_id? }) -- the same shape a CSV row or the edit
# form produces. Items are the source of truth; cards are item_id + progress.
module DataSets
  module Projection
    extend self

    FRONT = "Front"
    BACK = "Back"
    SEPARATOR = "; "
    # Fields a Replace preserves on a kept card when the CSV omits the column.
    PRESERVED = [:reading, :example_front, :example_back].freeze

    # Fresh build for ingest (Create / CopyDeck): rebuild the data_set from the
    # rows and create one thin card per row.
    def build(deck, rows)
      data_set = reset_data_set(deck)
      item_ids = insert_data(data_set, rows)
      insert_cards(deck, rows, item_ids)
      FlatCardSync.sync_deck(deck) if deck.flat_cards?
    end

    # Replace ingest: rebuild items from the new rows while preserving the
    # progress of cards whose front survives (matched by front text).
    def replace(deck, rows)
      sibling_formers = sibling_former_states(deck)
      former = former_states(deck)
      rows = preserve_omitted(rows, former)
      data_set = deck.data_set
      item_ids = upsert_data(data_set, rows)
      summary = reconcile_cards(deck, rows, item_ids, former)
      prune_items(data_set, item_ids.values)
      reconcile_siblings(deck, sibling_formers)
      refresh_deck_cards(deck)
      summary
    end

    # Re-project a single card from edited content (edit / accept suggestion).
    def project(card, content)
      sibling_formers = sibling_former_states(card.deck)
      former_front = card.item
      former_backs = back_items_for(former_front)

      front = repoint_card(card, content)

      former_front.destroy! if former_front != front
      discard_orphans(former_backs)
      reconcile_siblings(card.deck, sibling_formers)
      FlatCardSync.sync_card(card) if card.deck.flat_cards?
    end

    # Whether another card in the deck already owns a Front item with this text
    # (front must stay 1:1 with a card).
    def front_taken?(card, front)
      card.deck.cards.joins(:item)
        .where(items: { text: front }).where.not(id: card.id).exists?
    end

    # Record a wrong-guess distractor as an item reference. The decoy lives on
    # the side opposite the prompt (a reverse miss is a Front-side decoy), so it
    # stays an unpaired item and never spawns a card.
    def add_distractor(card, text)
      prompt = card.item
      decoy_side = prompt.side == FRONT ? BACK : FRONT
      decoy = prompt.data_set.items.find_or_create_by!(side: decoy_side, text:)
      ItemDistractor.find_or_create_by!(item: prompt, distractor_item: decoy)
      FlatCardSync.add_distractor(card, text) if card.deck.flat_cards?
    end

    def remove_card(card)
      front = card.item
      sibling_formers = sibling_former_states(card.deck)
      backs = back_items_for(front)
      front.destroy!
      discard_orphans(backs)
      reconcile_siblings(card.deck, sibling_formers)
    end

    # Ensure a deck has exactly one card per paired item on its anchor side,
    # preserving progress for survivors (matched by item text). Also builds a
    # reverse deck's cards on creation (formers empty, no existing cards).
    def reconcile_deck(deck, formers)
      wanted = anchor_items(deck).index_by(&:text)
      existing = existing_by_text(deck, formers)
      sync_wanted(deck, wanted, existing, formers)
      (existing.keys - wanted.keys).each { |text| existing[text].destroy! }
      # Cards were created/destroyed outside the loaded association above.
      deck.cards.reset
    end

    private

    def repoint_card(card, content)
      data_set = card.deck.data_set
      front = upsert_front(data_set, content)
      rebuild_links(data_set, front, content)
      card.update_column(:item_id, front.id)
      front
    end

    def refresh_deck_cards(deck)
      deck.cards.reset
      FlatCardSync.sync_deck(deck) if deck.flat_cards?
    end

    def preserve_omitted(rows, former)
      rows.map do |row|
        state = former[row[:front]]
        next row unless state

        PRESERVED.each_with_object(row.dup) do |key, merged|
          merged[key] = state[key] unless row.key?(key)
        end
      end
    end

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

    def upsert_data(data_set, rows)
      item_ids = upsert_items(data_set, rows)
      clear_all_links(data_set)
      insert_pairings(rows, item_ids)
      insert_distractors(rows, item_ids)
      item_ids
    end

    def upsert_items(data_set, rows)
      result = Item.upsert_all(
        item_rows(data_set, rows),
        unique_by: [:data_set_id, :side, :text],
        returning: ["id", "side", "text"],
      )
      result.rows.to_h { |id, side, text| [[side, text], id] }
    end

    def clear_all_links(data_set)
      fronts = data_set.items.select(:id)
      Pairing.where(item_id: fronts).delete_all
      ItemDistractor.where(item_id: fronts).delete_all
    end

    def prune_items(data_set, keep_ids)
      data_set.items.where.not(id: keep_ids).delete_all
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

    def former_states(deck)
      deck.cards.to_h do |card|
        [card.item.text, former_state(card)]
      end
    end

    def former_state(card)
      {
        card:,
        back: card.back,
        reading: card.reading,
        example_front: card.example_front,
        example_back: card.example_back,
      }
    end

    def reconcile_cards(deck, rows, item_ids, former)
      counts = { kept: 0, reset: 0 }
      added = []
      rows.each do |row|
        outcome = reconcile_existing(row, item_ids, former)
        outcome ? counts[outcome] += 1 : added << row
      end
      removed = remove_vanished(rows, former)
      insert_cards(deck, added, item_ids)
      { added: added.size, removed:, **counts }
    end

    def remove_vanished(rows, former)
      vanished = former.keys - rows.pluck(:front)
      vanished.each { |front| former[front][:card].destroy! }
      vanished.size
    end

    def reconcile_existing(row, item_ids, former)
      state = former[row[:front]]
      return unless state

      card = state[:card]
      card.update_column(:item_id, item_ids.fetch([FRONT, row[:front]]))
      return :kept if state[:back] == glosses(row).join(SEPARATOR)

      reset_progress(card)
      :reset
    end

    def reset_progress(card)
      card.update_columns(correct_streak: 0, correct_count: 0, view_count: 0)
    end

    def sibling_decks(deck)
      deck.data_set.decks.where.not(id: deck.id)
    end

    def sibling_former_states(deck)
      sibling_decks(deck).to_h { |sibling| [sibling.id, deck_states(sibling)] }
    end

    def deck_states(deck)
      deck.cards.to_h do |card|
        [card.id, { text: card.item.text, back: card.back }]
      end
    end

    def reconcile_siblings(deck, sibling_formers)
      sibling_decks(deck).each do |sibling|
        reconcile_deck(sibling, sibling_formers[sibling.id] || {})
      end
    end

    def sync_wanted(deck, wanted, existing, formers)
      wanted.each do |text, item|
        card = existing[text]
        if card
          refresh_card(card, item, formers[card.id])
        else
          create_anchor_card(deck, item)
        end
      end
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

    # Existing cards keyed by item text. Callers pass formers covering every
    # card (sibling sync) or an empty deck (reverse-deck build), so a card's
    # former text is always available.
    def existing_by_text(deck, formers)
      deck.cards.index_by { |card| formers.dig(card.id, :text) }
    end

    def refresh_card(card, item, former)
      card.item = item
      card.update_column(:item_id, item.id)
      reset_progress(card) if former[:back] != card.back
    end

    def create_anchor_card(deck, item)
      deck.card_type.constantize.create!(deck:, item:)
    end

    def upsert_front(data_set, content)
      front =
        data_set.items.find_or_initialize_by(side: FRONT, text: content[:front])
      front.update!(front_attributes(content))
      front
    end

    def rebuild_links(data_set, front, content)
      clear_links(front)
      pair_glosses(data_set, front, glosses(content))
      link_distractors(data_set, front, terms(content[:distractors]))
    end

    def front_attributes(content)
      {
        category: content[:category],
        reading: content[:reading],
        example: content[:example_front],
        paired_example: content[:example_back],
      }
    end

    def clear_links(front)
      Pairing.where(item_id: front.id).delete_all
      ItemDistractor.where(item_id: front.id).delete_all
    end

    def pair_glosses(data_set, front, glosses)
      glosses.each do |gloss|
        back = data_set.items.find_or_create_by!(side: BACK, text: gloss)
        Pairing.create!(item: front, paired_item: back)
      end
    end

    def link_distractors(data_set, front, distractors)
      distractors.each do |distractor|
        back = data_set.items.find_or_create_by!(side: BACK, text: distractor)
        ItemDistractor.create!(item: front, distractor_item: back)
      end
    end

    def glosses(content)
      terms(content[:back].to_s.split(";"))
    end

    def terms(values)
      Array(values).map { |value| value.to_s.squish }.compact_blank.uniq
    end

    def back_items_for(front)
      paired = Pairing.where(item_id: front.id).select(:paired_item_id)
      decoys =
        ItemDistractor.where(item_id: front.id).select(:distractor_item_id)
      Item.where(id: paired).or(Item.where(id: decoys)).to_a
    end

    def discard_orphans(items)
      items.each do |item|
        next if Pairing.exists?(paired_item_id: item.id)
        next if ItemDistractor.exists?(distractor_item_id: item.id)

        item.destroy!
      end
    end
  end
end
