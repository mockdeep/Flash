# frozen_string_literal: true

# Mirrors a deck's card content into its data_set (items, pairings,
# item_distractors) during the transition where cards remain the source of
# truth. Each card projects to one Front item (1:1) plus a Back item per gloss
# and per distractor, deduped within the set by (side, text).
module DataSets
  module Projection
    FRONT = "Front"
    BACK = "Back"

    def self.rebuild(deck)
      data_set = data_set_for(deck)
      data_set.items.delete_all
      deck.cards.reload.each { |card| project_card(card) }
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
