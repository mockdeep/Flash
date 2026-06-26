# frozen_string_literal: true

module Helpers
  # Drift oracle for the data_set dual-write: derives the projection a deck's
  # cards *should* produce (independently of DataSets::Projection) and compares
  # it to the live data_set, so any path that mirrors incorrectly is caught.
  module DataSetProjectionHelpers
    BACK_ATTRS = {
      category: nil, reading: nil, example: nil, paired_example: nil
    }.freeze

    def expect_projection_matches(deck)
      expect(actual_projection(deck)).to eq(expected_projection(deck))
    end

    def expected_projection(deck)
      result = { items: {}, pairings: [], distractors: [] }
      deck.cards.each { |card| add_card(result, card) }
      result[:pairings].sort!
      result[:distractors].sort!
      result
    end

    def add_card(result, card)
      result[:items][["Front", card.front]] = front_attrs(card)
      decoys = split(card.distractors.join(";"))
      add_side(result, :pairings, card.front, split(card.back))
      add_side(result, :distractors, card.front, decoys)
    end

    def add_side(result, key, front, texts)
      texts.each do |text|
        result[:items][["Back", text]] ||= BACK_ATTRS
        result[key] << [front, text]
      end
    end

    def actual_projection(deck)
      data_set = deck.reload.data_set
      return { items: {}, pairings: [], distractors: [] } unless data_set

      by_id = data_set.items.index_by(&:id)
      {
        items: by_id.values.to_h { |i| [[i.side, i.text], item_attrs(i)] },
        pairings: link_pairs(Pairing, by_id, :paired_item_id),
        distractors: link_pairs(ItemDistractor, by_id, :distractor_item_id),
      }
    end

    def link_pairs(model, by_id, target)
      model.where(item_id: by_id.keys)
        .map { |row| [by_id[row.item_id].text, by_id[row[target]].text] }
        .sort
    end

    def front_attrs(card)
      {
        category: card.category,
        reading: card.reading,
        example: card.example_front,
        paired_example: card.example_back,
      }
    end

    def item_attrs(item)
      item.slice(:category, :reading, :example, :paired_example).symbolize_keys
    end

    def split(value)
      value.to_s.split(";").map(&:squish).compact_blank.uniq
    end
  end
end

RSpec.configure do |config|
  config.include(Helpers::DataSetProjectionHelpers)
end
