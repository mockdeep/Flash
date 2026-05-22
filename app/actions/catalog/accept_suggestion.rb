# frozen_string_literal: true

module Catalog
  module AcceptSuggestion
    def self.call(suggestion:)
      ActiveRecord::Base.transaction do
        apply_to_card(suggestion)
        suggestion.update!(state: "accepted")
      end
      Result.new(success: true, record: suggestion)
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success: false, record: e.record)
    end

    def self.apply_to_card(suggestion)
      suggestion.card.update!(
        front: suggestion.front,
        back: suggestion.back,
        category: suggestion.category,
      )
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
