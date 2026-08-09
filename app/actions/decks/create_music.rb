# frozen_string_literal: true

module Decks
  module CreateMusic
    extend self

    def call(user:, name:, cards_csv:, ordered: false)
      deck = build_deck(user:, name:, ordered:)
      csv = CardsCsv.parse(cards_csv)

      error = validate_csv(csv)
      return failure(deck, error) if error

      persist(deck, csv)
    end

    private

    def build_deck(user:, name:, ordered:)
      MusicDeck.new(name:, user:, ordered:, study_goal: user.study_goal)
    end

    def persist(deck, csv)
      ActiveRecord::Base.transaction do
        return failure(deck) unless deck.save

        FlatCards.build(deck, card_rows(csv))
      end

      Result.new(success: true, record: deck)
    end

    def failure(deck, error = nil)
      deck.errors.add(:cards_csv, error) if error
      Result.new(success: false, record: deck)
    end

    def validate_csv(csv)
      CardsCsv.validate_headers(csv) ||
        CardsCsv.validate_present(csv) ||
        validate_rows(csv) ||
        CardsCsv.validate_unique_fronts(csv)
    end

    def validate_rows(csv)
      csv.each_with_index do |row, index|
        error = validate_row(row, index)
        return error if error
      end

      nil
    end

    def validate_row(row, index)
      front = row["front"].to_s.squish
      back = row["back"].to_s.squish
      if front.blank? || back.blank?
        return "row #{index + 1} is missing a 'front' or 'back' value"
      end
      return if back.match?(MusicCard::NOTE_REGEXP)

      "row #{index + 1}: '#{back}' is not a valid note"
    end

    def card_rows(csv)
      csv.map do |row|
        {
          front: row["front"].squish,
          back: row["back"].squish,
          category: row["category"].to_s.squish,
        }
      end
    end
  end
end
