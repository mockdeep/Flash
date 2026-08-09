# frozen_string_literal: true

# Card writer for the flat-card families (Basic, Music): cards own their
# content columns and distractors directly, no data_set projection. Mirrors
# DataSets::Projection's interface - decks dispatch to one or the other via
# Deck#card_writer. A "row" is the same content hash the projection consumes.
module Decks
  module FlatCards
    extend self

    # Fields a Replace preserves on a kept card when the CSV omits the column.
    PRESERVED = [:reading, :example_front, :example_back].freeze

    def build(deck, rows)
      return if rows.empty?

      result = Card.insert_all(
        rows.map { |row| card_row(deck, row) }, returning: ["id", "front"]
      )
      ids = result.rows.to_h { |id, front| [front, id] }
      insert_distractors(rows, ids)
    end

    # Replace ingest: reconcile rows against existing cards by front,
    # preserving the progress of cards whose back survives unchanged.
    def replace(deck, rows)
      former = deck.cards.index_by(&:front)
      rows = preserve_omitted(rows, former)
      counts = reconcile_kept(rows, former)
      added = rows.reject { |row| former.key?(row[:front]) }
      removed = remove_vanished(rows, former)
      build(deck, added)
      deck.cards.reset
      { added: added.size, removed:, **counts }
    end

    # Re-write a single card from edited content (edit / accept suggestion).
    def project(card, content)
      card.update!(content_attributes(content))
      replace_distractors(card, content[:distractors] || [])
    end

    def remove_card(card)
      card.destroy!
    end

    # Whether another card in the deck already owns this front text.
    def front_taken?(card, front)
      card.deck.cards.where(front:).where.not(id: card.id).exists?
    end

    private

    def card_row(deck, row)
      {
        deck_id: deck.id,
        type: deck.card_type,
        source_card_id: row[:source_card_id],
        **content_attributes(row),
      }
    end

    def content_attributes(row)
      {
        front: row[:front],
        back: Card.normalize_value_for(:back, row[:back]),
        category: row[:category],
        reading: row[:reading],
        example_front: row[:example_front],
        example_back: row[:example_back],
      }
    end

    def insert_distractors(rows, ids)
      distractors =
        rows.flat_map do |row|
          Array(row[:distractors]).map do |text|
            { card_id: ids[row[:front]], text: }
          end
        end
      CardDistractor.insert_all(distractors) if distractors.any?
    end

    def preserve_omitted(rows, former)
      rows.map do |row|
        card = former[row[:front]]
        next row unless card

        PRESERVED.each_with_object(row.dup) do |key, merged|
          merged[key] = card[key] unless row.key?(key)
        end
      end
    end

    def reconcile_kept(rows, former)
      counts = { kept: 0, reset: 0 }
      rows.each do |row|
        card = former[row[:front]]
        counts[reconcile_card(card, row)] += 1 if card
      end
      counts
    end

    def reconcile_card(card, row)
      back_survives = card.back == Card.normalize_value_for(:back, row[:back])
      card.update!(content_attributes(row))
      replace_distractors(card, Array(row[:distractors]))
      return :kept if back_survives

      card.update!(correct_streak: 0, correct_count: 0, view_count: 0)
      :reset
    end

    def remove_vanished(rows, former)
      vanished = former.keys - rows.pluck(:front)
      vanished.each { |front| former[front].destroy! }
      vanished.size
    end

    def replace_distractors(card, texts)
      card.card_distractors.where.not(text: texts).delete_all
      texts.each { |text| card.card_distractors.find_or_create_by!(text:) }
    end
  end
end
