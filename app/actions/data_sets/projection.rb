# frozen_string_literal: true

# Mirrors a deck's card content into its data_set (items, pairings,
# item_distractors) during the transition where cards remain the source of
# truth. Each card projects to one Front item (1:1) plus a Back item per gloss
# and per distractor, deduped within the set by (side, text).
module DataSets
  module Projection
    FRONT = "Front"
    BACK = "Back"

    # Bulk-rebuilds a deck's whole data_set in a handful of set-based queries,
    # rather than per-card find_or_create. Used by ingest and the backfill.
    def self.rebuild(deck)
      data_set = data_set_for(deck)
      data_set.items.delete_all
      cards = deck.cards.reload.to_a
      return if cards.empty?

      insert_content(data_set, cards)
      # link_cards writes item_id via upsert_all, so drop the now-stale cache.
      deck.cards.reset
    end

    def self.insert_content(data_set, cards)
      item_ids = insert_items(data_set, cards)
      insert_pairings(cards, item_ids)
      insert_distractors(cards, item_ids)
      link_cards(cards, item_ids)
    end

    def self.insert_items(data_set, cards)
      rows = item_rows(data_set, cards)
      result = Item.insert_all(rows, returning: ["id", "side", "text"])
      result.rows.to_h { |id, side, text| [[side, text], id] }
    end

    def self.item_rows(data_set, cards)
      rows = {}
      cards.each do |card|
        rows[[FRONT, card.front]] = front_row(data_set, card)
        back_texts(card).each do |text|
          rows[[BACK, text]] ||= back_row(data_set, text)
        end
      end
      rows.values
    end

    def self.back_texts(card)
      glosses(card) + terms(card.distractors)
    end

    def self.front_row(data_set, card)
      {
        data_set_id: data_set.id,
        side: FRONT,
        text: card.front,
        **front_attributes(card),
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

    def self.insert_pairings(cards, item_ids)
      rows =
        cards.flat_map do |card|
          front_id = item_ids[[FRONT, card.front]]
          glosses(card).map do |gloss|
            { item_id: front_id, paired_item_id: item_ids[[BACK, gloss]] }
          end
        end
      Pairing.insert_all(rows) if rows.any?
    end

    def self.insert_distractors(cards, item_ids)
      rows =
        cards.flat_map do |card|
          front_id = item_ids[[FRONT, card.front]]
          terms(card.distractors).map do |text|
            { item_id: front_id, distractor_item_id: item_ids[[BACK, text]] }
          end
        end
      ItemDistractor.insert_all(rows) if rows.any?
    end

    def self.link_cards(cards, item_ids)
      rows =
        cards.map do |card|
          card.attributes.merge("item_id" => item_ids[[FRONT, card.front]])
        end
      Card.upsert_all(
        rows,
        unique_by: :id,
        update_only: [:item_id],
        record_timestamps: false,
      )
    end

    def self.project_card(card)
      data_set = data_set_for(card.deck)
      former_front = card.item
      former_backs = back_items_for(former_front)

      front = upsert_front(data_set, card)
      rebuild_links(data_set, front, card)
      link_card(card, front)

      former_front.destroy! if former_front && former_front != front
      discard_orphans(former_backs)
    end

    def self.remove_card(card)
      front = card.item
      return unless front

      backs = back_items_for(front)
      front.destroy!
      discard_orphans(backs)
    end

    def self.data_set_for(deck)
      deck.data_set || create_data_set(deck)
    end

    def self.create_data_set(deck)
      data_set = DataSet.create!(user: deck.user, name: deck.name)
      deck.update!(data_set:)
      data_set
    end

    def self.upsert_front(data_set, card)
      front =
        data_set.items.find_or_initialize_by(side: FRONT, text: card.front)
      front.update!(front_attributes(card))
      front
    end

    def self.rebuild_links(data_set, front, card)
      clear_links(front)
      pair_glosses(data_set, front, glosses(card))
      link_distractors(data_set, front, terms(card.distractors))
    end

    def self.link_card(card, front)
      # item_id is a derived link, kept off the card's timestamps/callbacks.
      card.update_column(:item_id, front.id)
    end

    def self.front_attributes(card)
      {
        category: card.category,
        reading: card.reading,
        example: card.example_front,
        paired_example: card.example_back,
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

    def self.glosses(card)
      terms(card.back.to_s.split(";"))
    end

    def self.terms(values)
      values.map { |value| value.to_s.squish }.compact_blank.uniq
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
