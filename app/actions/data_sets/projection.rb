# frozen_string_literal: true

# Builds a deck's data_set (items, pairings, item_distractors) and its thin
# cards from content rows. A "row" is a hash of card content
# ({ front:, back:, category:, distractors:, reading:, example_front:,
# example_back:, source_card_id? }) -- the same shape a CSV row or the edit
# form produces. Items are the source of truth; cards are item_id + progress.
module DataSets
  module Projection
    FRONT = "Front"
    BACK = "Back"
    SEPARATOR = "; "
    # Fields a Replace preserves on a kept card when the CSV omits the column.
    PRESERVED = [:reading, :example_front, :example_back].freeze

    # Fresh build for ingest (Create / CopyDeck): rebuild the data_set from the
    # rows and create one thin card per row.
    def self.build(deck, rows)
      data_set = reset_data_set(deck)
      item_ids = insert_data(data_set, rows)
      insert_cards(deck, rows, item_ids)
    end

    # Replace ingest: rebuild items from the new rows while preserving the
    # progress of cards whose front survives (matched by front text).
    def self.replace(deck, rows)
      former = former_states(deck)
      rows = preserve_omitted(rows, former)
      data_set = reset_data_set(deck)
      item_ids = insert_data(data_set, rows)
      reconcile_cards(deck, rows, item_ids, former)
    end

    def self.preserve_omitted(rows, former)
      rows.map do |row|
        state = former[row[:front]]
        next row unless state

        PRESERVED.each_with_object(row.dup) do |key, merged|
          merged[key] = state[key] unless row.key?(key)
        end
      end
    end

    # Re-project a single card from edited content (edit / accept suggestion).
    def self.project(card, content)
      data_set = data_set_for(card.deck)
      former_front = card.item
      former_backs = back_items_for(former_front)

      front = upsert_front(data_set, content)
      rebuild_links(data_set, front, content)
      card.update_column(:item_id, front.id)

      former_front.destroy! if former_front && former_front != front
      discard_orphans(former_backs)
    end

    # Re-project from a card's own columns (test factory only -- production
    # writes go through build/replace/project from the source content).
    def self.project_card(card)
      project(card, content_for(card))
    end

    # Whether another card in the deck already owns a Front item with this text
    # (front must stay 1:1 with a card).
    def self.front_taken?(card, front)
      card.deck.cards.joins(:item)
        .where(items: { text: front }).where.not(id: card.id).exists?
    end

    # Record a wrong-guess distractor as an item reference.
    def self.add_distractor(card, text)
      front = card.item
      back = front.data_set.items.find_or_create_by!(side: BACK, text:)
      ItemDistractor.find_or_create_by!(item: front, distractor_item: back)
    end

    def self.remove_card(card)
      front = card.item
      return unless front

      backs = back_items_for(front)
      front.destroy!
      discard_orphans(backs)
    end

    def self.reset_data_set(deck)
      data_set = data_set_for(deck)
      data_set.items.delete_all
      data_set
    end

    def self.insert_data(data_set, rows)
      return {} if rows.empty?

      item_ids = insert_items(data_set, rows)
      insert_pairings(rows, item_ids)
      insert_distractors(rows, item_ids)
      item_ids
    end

    def self.insert_items(data_set, rows)
      result = Item.insert_all(
        item_rows(data_set, rows),
        returning: ["id", "side", "text"],
      )
      result.rows.to_h { |id, side, text| [[side, text], id] }
    end

    def self.item_rows(data_set, rows)
      items = {}
      rows.each do |row|
        items[[FRONT, row[:front]]] = front_row(data_set, row)
        back_texts(row).each do |text|
          items[[BACK, text]] ||= back_row(data_set, text)
        end
      end
      items.values
    end

    def self.back_texts(row)
      glosses(row) + terms(row[:distractors])
    end

    def self.front_row(data_set, row)
      {
        data_set_id: data_set.id,
        side: FRONT,
        text: row[:front],
        **front_attributes(row),
      }
    end

    def self.back_row(data_set, text)
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

    def self.insert_pairings(rows, item_ids)
      pairings =
        rows.flat_map do |row|
          front_id = item_ids[[FRONT, row[:front]]]
          glosses(row).map do |gloss|
            { item_id: front_id, paired_item_id: item_ids[[BACK, gloss]] }
          end
        end
      Pairing.insert_all(pairings) if pairings.any?
    end

    def self.insert_distractors(rows, item_ids)
      distractors =
        rows.flat_map do |row|
          front_id = item_ids[[FRONT, row[:front]]]
          terms(row[:distractors]).map do |text|
            { item_id: front_id, distractor_item_id: item_ids[[BACK, text]] }
          end
        end
      ItemDistractor.insert_all(distractors) if distractors.any?
    end

    def self.insert_cards(deck, rows, item_ids)
      return if rows.empty?

      Card.insert_all(rows.map { |row| card_row(deck, row, item_ids) })
    end

    def self.card_row(deck, row, item_ids)
      {
        deck_id: deck.id,
        type: "TextCard",
        item_id: item_ids[[FRONT, row[:front]]],
        source_card_id: row[:source_card_id],
      }
    end

    def self.former_states(deck)
      deck.cards.includes(item: { pairings: :paired_item }).to_h do |card|
        [card.item.text, former_state(card)]
      end
    end

    def self.former_state(card)
      content = CardContent.new(card)
      {
        card:,
        back: content.back,
        reading: content.reading,
        example_front: content.example_front,
        example_back: content.example_back,
      }
    end

    def self.reconcile_cards(deck, rows, item_ids, former)
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

    def self.remove_vanished(rows, former)
      vanished = former.keys - rows.pluck(:front)
      vanished.each { |front| former[front][:card].destroy! }
      vanished.size
    end

    def self.reconcile_existing(row, item_ids, former)
      state = former[row[:front]]
      return unless state

      card = state[:card]
      card.update_column(:item_id, item_ids[[FRONT, row[:front]]])
      return :kept if state[:back] == glosses(row).join(SEPARATOR)

      reset_progress(card)
      :reset
    end

    def self.reset_progress(card)
      card.update_columns(correct_streak: 0, correct_count: 0, view_count: 0)
    end

    def self.upsert_front(data_set, content)
      front =
        data_set.items.find_or_initialize_by(side: FRONT, text: content[:front])
      front.update!(front_attributes(content))
      front
    end

    def self.rebuild_links(data_set, front, content)
      clear_links(front)
      pair_glosses(data_set, front, glosses(content))
      link_distractors(data_set, front, terms(content[:distractors]))
    end

    def self.front_attributes(content)
      {
        category: content[:category],
        reading: content[:reading],
        example: content[:example_front],
        paired_example: content[:example_back],
      }
    end

    def self.clear_links(front)
      Pairing.where(item_id: front.id).delete_all
      ItemDistractor.where(item_id: front.id).delete_all
    end

    def self.pair_glosses(data_set, front, glosses)
      glosses.each do |gloss|
        back = data_set.items.find_or_create_by!(side: BACK, text: gloss)
        Pairing.create!(item: front, paired_item: back)
      end
    end

    def self.link_distractors(data_set, front, distractors)
      distractors.each do |distractor|
        back = data_set.items.find_or_create_by!(side: BACK, text: distractor)
        ItemDistractor.create!(item: front, distractor_item: back)
      end
    end

    def self.glosses(content)
      terms(content[:back].to_s.split(";"))
    end

    def self.terms(values)
      Array(values).map { |value| value.to_s.squish }.compact_blank.uniq
    end

    def self.content_for(card)
      {
        front: card.front,
        back: card.back,
        category: card.category,
        distractors: card.distractors,
        reading: card.reading,
        example_front: card.example_front,
        example_back: card.example_back,
      }
    end

    def self.data_set_for(deck)
      deck.data_set || create_data_set(deck)
    end

    def self.create_data_set(deck)
      data_set = DataSet.create!(user: deck.user, name: deck.name)
      deck.update!(data_set:)
      data_set
    end

    def self.back_items_for(front)
      return [] unless front

      paired = Pairing.where(item_id: front.id).select(:paired_item_id)
      decoys =
        ItemDistractor.where(item_id: front.id).select(:distractor_item_id)
      Item.where(id: paired).or(Item.where(id: decoys)).to_a
    end

    def self.discard_orphans(items)
      items.each do |item|
        next if Pairing.exists?(paired_item_id: item.id)
        next if ItemDistractor.exists?(distractor_item_id: item.id)

        item.destroy!
      end
    end
  end
end
