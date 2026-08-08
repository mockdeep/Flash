# frozen_string_literal: true

module Decks
  module CreateLanguage
    extend self

    def call(user:, name:, cards_csv:, language:)
      deck = ReadingDeck.new(
        study_goal: user.study_goal,
        data_set: LanguageDataSet.new(user:, name:, language:),
      )
      csv = CardsCsv.parse(cards_csv)

      error = CardsCsv.validate(csv)
      return failure(deck, error) if error

      deck.distractor_pool =
        CardsCsv.distractors_column?(csv) ? "preset" : "category"
      persist(deck, csv)
    end

    private

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
