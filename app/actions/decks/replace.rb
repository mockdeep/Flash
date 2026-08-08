# frozen_string_literal: true

module Decks
  module Replace
    extend self

    Summary = Struct.new(:added, :removed, :reset, :kept)

    def call(deck:, cards_csv:)
      csv = CardsCsv.parse(cards_csv)

      error = CardsCsv.validate(csv)
      return failure(deck, error) if error

      summary = nil
      ActiveRecord::Base.transaction do
        deck.update!(distractor_pool: derive_distractor_pool(csv))
        rows = CardsCsv.rows(csv)
        summary = Summary.new(**DataSets::Projection.replace(deck, rows))
      end

      Result.new(success: true, record: deck, summary:)
    end

    private

    def derive_distractor_pool(csv)
      CardsCsv.distractors_column?(csv) ? "preset" : "category"
    end

    def failure(deck, error)
      deck.errors.add(:cards_csv, error)
      Result.new(success: false, record: deck, summary: nil)
    end
  end
end
