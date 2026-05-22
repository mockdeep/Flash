# frozen_string_literal: true

require "csv"

module Decks
  module Replace
    Summary = Struct.new(:added, :removed, :reset, :kept)

    def self.call(deck:, cards_csv:)
      csv = CSV.parse(cards_csv.read, headers: true)

      error = Decks::Create.validate_csv(csv)
      return failure(deck, error) if error

      summary = nil
      ActiveRecord::Base.transaction do
        deck.update!(distractor_pool: derive_distractor_pool(csv))
        summary = apply_diff(deck, Decks::Create.collect_cards_data(csv))
      end

      Result.new(success: true, record: deck, summary:)
    end

    def self.derive_distractor_pool(csv)
      Decks::Create.distractors_column?(csv) ? "preset" : "category"
    end

    def self.failure(deck, error)
      deck.errors.add(:cards_csv, error)
      Result.new(success: false, record: deck, summary: nil)
    end

    def self.apply_diff(deck, cards_data)
      existing = Card.where(deck_id: deck.id).index_by(&:front)
      incoming = cards_data.index_by { |d| d[:front] }

      removed = remove_missing_cards(existing, incoming)
      reset, kept = update_kept_cards(existing, incoming)
      added = insert_new_cards(deck, existing, incoming)

      Summary.new(added:, removed:, reset:, kept:)
    end

    def self.remove_missing_cards(existing, incoming)
      ids = (existing.keys - incoming.keys).map { |front| existing[front].id }
      Card.where(id: ids).delete_all if ids.any?
      ids.length
    end

    def self.update_kept_cards(existing, incoming)
      counts = { reset: 0, kept: 0 }
      (existing.keys & incoming.keys).each do |front|
        counts[update_one_kept(existing[front], incoming[front])] += 1
      end
      counts.values_at(:reset, :kept)
    end

    def self.update_one_kept(card, data)
      if card.back == data[:back]
        update_card_metadata(card, data)
        :kept
      else
        update_card_with_reset(card, data)
        :reset
      end
    end

    def self.update_card_metadata(card, data)
      return if metadata_unchanged?(card, data)

      card.update!(category: data[:category], distractors: data[:distractors])
    end

    def self.metadata_unchanged?(card, data)
      card.category == data[:category] &&
        card.distractors == data[:distractors]
    end

    def self.update_card_with_reset(card, data)
      card.update!(
        back: data[:back],
        category: data[:category],
        distractors: data[:distractors],
        correct_streak: 0,
        correct_count: 0,
        view_count: 0,
      )
    end

    def self.insert_new_cards(deck, existing, incoming)
      new_fronts = incoming.keys - existing.keys
      return 0 if new_fronts.empty?

      cards_attributes =
        new_fronts.map { |front| build_card_attributes(deck, incoming[front]) }
      Card.insert_all(cards_attributes)
      new_fronts.length
    end

    def self.build_card_attributes(deck, data)
      TextCard.new(deck:, **data)
        .attributes.without("id", "created_at", "updated_at")
    end

    class Result
      attr_accessor :success, :record, :summary

      def initialize(success:, record:, summary:)
        self.success = success
        self.record = record
        self.summary = summary
      end

      def success?
        success
      end
    end
  end
end
