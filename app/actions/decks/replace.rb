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
        rows = Decks::Create.collect_cards_data(csv)
        summary = Summary.new(**DataSets::Projection.replace(deck, rows))
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
