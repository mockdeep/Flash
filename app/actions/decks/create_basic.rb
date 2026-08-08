# frozen_string_literal: true

module Decks
  module CreateBasic
    extend self

    def call(user:, name:, cards_csv:)
      deck = build_deck(user:, name:)
      csv = CardsCsv.parse(cards_csv)

      error = CardsCsv.validate(csv)
      return failure(deck, error) if error

      deck.distractor_pool =
        CardsCsv.distractors_column?(csv) ? "preset" : "category"
      persist(deck, csv)
    end

    private

    def build_deck(user:, name:)
      BasicDeck.new(
        name:,
        user:,
        study_goal: user.study_goal,
        data_set: BasicDataSet.new(user:, name:),
      )
    end

    def persist(deck, csv)
      ActiveRecord::Base.transaction do
        return failure(deck) unless deck.save

        DataSets::Projection.build(deck, CardsCsv.rows(csv))
      end

      Result.new(success: true, record: deck)
    end

    def failure(deck, error = nil)
      deck.errors.add(:cards_csv, error) if error
      Result.new(success: false, record: deck)
    end
  end
end
