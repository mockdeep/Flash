# frozen_string_literal: true

require "csv"

module Decks
  module Create
    def self.call(user:, name:, cards_csv:)
      deck = TextDeck.new(name:, study_goal: user.study_goal)
      csv = CSV.parse(cards_csv.read, headers: true)

      error = validate_csv(csv)
      return failure(deck, error) if error

      deck.distractor_pool = distractors_column?(csv) ? "preset" : "category"

      ActiveRecord::Base.transaction do
        deck.user = user
        return failure(deck) unless deck.save

        build_and_insert_cards(deck, collect_cards_data(csv))
      end

      Result.new(success: true, record: deck)
    end

    def self.failure(deck, error = nil)
      deck.errors.add(:cards_csv, error) if error
      Result.new(success: false, record: deck)
    end

    def self.validate_csv(csv)
      validate_csv_headers(csv) ||
        validate_csv_rows(csv) ||
        validate_unique_fronts(csv) ||
        validate_distractors_present(csv)
    end

    def self.validate_csv_headers(csv)
      headers = csv.headers.map { |h| h.to_s.strip.downcase }
      return if headers.include?("front") && headers.include?("back")

      "must include 'front' and 'back' columns"
    end

    def self.validate_csv_rows(csv)
      csv.each_with_index do |row, index|
        next if row["front"]&.squish.present? &&
          row["back"]&.squish.present?

        return "row #{index + 1} is missing a " \
               "'front' or 'back' value"
      end

      nil
    end

    def self.validate_unique_fronts(csv)
      fronts = csv.map { |row| row["front"].squish }
      duplicates = fronts.tally.select { |_, count| count > 1 }.keys
      return if duplicates.empty?

      "duplicate 'front' values: #{duplicates.join(", ")}"
    end

    def self.validate_distractors_present(csv)
      return unless distractors_column?(csv)

      csv.each_with_index do |row, index|
        next if parse_distractors(row).any?

        return "row #{index + 1} is missing a 'distractors' value"
      end

      nil
    end

    def self.distractors_column?(csv)
      csv.headers.include?("distractors")
    end

    def self.parse_distractors(row)
      row["distractors"].to_s.split(";").map(&:squish).reject(&:empty?)
    end

    def self.collect_cards_data(csv)
      with_distractors = distractors_column?(csv)

      csv.map do |row|
        {
          front: row["front"].squish,
          back: row["back"].squish,
          category: row["category"].to_s.squish,
          distractors: with_distractors ? parse_distractors(row) : [],
        }
      end
    end

    def self.build_and_insert_cards(deck, cards_data)
      cards_attributes =
        cards_data.map do |data|
          card = TextCard.new(
            deck:,
            front: data[:front],
            back: data[:back],
            category: data[:category],
            distractors: data[:distractors],
          )
          card.attributes.without("id", "created_at", "updated_at")
        end

      Card.insert_all(cards_attributes)
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
