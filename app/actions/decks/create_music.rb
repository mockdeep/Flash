# frozen_string_literal: true

require "csv"

module Decks
  module CreateMusic
    def self.call(user:, name:, cards_csv:, ordered: false)
      deck = MusicDeck.new(
        ordered:,
        study_goal: user.study_goal,
        data_set: DataSet.new(user:, name:),
      )
      csv = CSV.parse(cards_csv.read, headers: true)

      error = validate_csv(csv)
      return failure(deck, error) if error

      persist(deck, user, csv)
    end

    def self.persist(deck, user, csv)
      ActiveRecord::Base.transaction do
        deck.user = user
        return failure(deck) unless deck.save

        DataSets::Projection.build(deck, card_rows(csv))
      end

      Result.new(success: true, record: deck)
    end

    def self.failure(deck, error = nil)
      deck.errors.add(:cards_csv, error) if error
      Result.new(success: false, record: deck)
    end

    def self.validate_csv(csv)
      validate_headers(csv) ||
        validate_rows(csv) ||
        validate_unique_fronts(csv)
    end

    def self.validate_headers(csv)
      headers = csv.headers.map { |h| h.to_s.strip.downcase }
      return if headers.include?("front") && headers.include?("back")

      "must include 'front' and 'back' columns"
    end

    def self.validate_rows(csv)
      csv.each_with_index do |row, index|
        error = validate_row(row, index)
        return error if error
      end

      nil
    end

    def self.validate_row(row, index)
      front = row["front"].to_s.squish
      back = row["back"].to_s.squish
      if front.blank? || back.blank?
        return "row #{index + 1} is missing a 'front' or 'back' value"
      end
      return if back.match?(MusicCard::NOTE_REGEXP)

      "row #{index + 1}: '#{back}' is not a valid note"
    end

    def self.validate_unique_fronts(csv)
      fronts = csv.map { |row| row["front"].squish }
      duplicates = fronts.tally.select { |_, count| count > 1 }.keys
      return if duplicates.empty?

      "duplicate 'front' values: #{duplicates.join(", ")}"
    end

    def self.card_rows(csv)
      csv.map do |row|
        {
          front: row["front"].squish,
          back: row["back"].squish,
          category: row["category"].to_s.squish,
        }
      end
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
