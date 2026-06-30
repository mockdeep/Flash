# frozen_string_literal: true

require "csv"

module Decks
  module Create
    def self.call(user:, name:, cards_csv:)
      deck = TextDeck.new(
        study_goal: user.study_goal,
        data_set: DataSet.new(user:, name:),
      )
      csv = parse_csv(cards_csv)

      error = validate_csv(csv)
      return failure(deck, error) if error

      deck.distractor_pool = distractors_column?(csv) ? "preset" : "category"
      persist(deck, csv)
    end

    def self.persist(deck, csv)
      ActiveRecord::Base.transaction do
        return failure(deck) unless deck.save

        DataSets::Projection.build(deck, collect_cards_data(csv))
      end

      Result.new(success: true, record: deck)
    end

    def self.parse_csv(cards_csv)
      CSV.parse(cards_csv.read.force_encoding("UTF-8"), headers: true)
    end

    def self.failure(deck, error = nil)
      deck.errors.add(:cards_csv, error) if error
      Result.new(success: false, record: deck)
    end

    def self.validate_csv(csv)
      validate_csv_headers(csv) ||
        CsvExamples.validate_headers(csv) ||
        validate_csv_rows(csv) ||
        validate_unique_fronts(csv) ||
        validate_distractors_present(csv) ||
        CsvExamples.validate_pairs(csv)
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
      with_examples = CsvExamples.present?(csv)
      with_reading = CsvReading.present?(csv)

      csv.map do |row|
        {
          front: row["front"].squish,
          back: row["back"].squish,
          category: row["category"].to_s.squish,
          distractors: with_distractors ? parse_distractors(row) : [],
          **(with_examples ? CsvExamples.attributes(row) : {}),
          **(with_reading ? CsvReading.attributes(row) : {}),
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
