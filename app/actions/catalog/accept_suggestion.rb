# frozen_string_literal: true

module Catalog
  module AcceptSuggestion
    extend self

    def call(suggestion:)
      ActiveRecord::Base.transaction do
        apply_to_card(suggestion)
        suggestion.update!(state: "accepted")
      end
      Result.new(success: true, record: suggestion)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success: false, record: e.record)
    end

    private

    def apply_to_card(suggestion)
      card = suggestion.card
      ensure_front_available!(card, suggestion.front)
      card.deck.card_writer.project(card, suggested_content(suggestion))
    end

    def suggested_content(suggestion)
      suggestion.card.to_row.merge(
        front: suggestion.front,
        back: suggestion.back,
        category: suggestion.category,
      )
    end

    def ensure_front_available!(card, front)
      return unless card.deck.card_writer.front_taken?(card, front)

      card.errors.add(:front, :taken)
      raise ActiveRecord::RecordInvalid, card
    end

    class Result
      attr_accessor :success, :record

      def initialize(success:, record:)
        self.success = success
        self.record = record
      end

      def success?
        success
      end
    end
  end
end
