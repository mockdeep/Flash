# frozen_string_literal: true

require "csv"

module Decks
  # Parsing, validation, and row collection for an uploaded cards CSV, shared
  # by the create and replace actions. A collected row is the content-hash
  # shape the projection consumes.
  module CardsCsv
    extend self

    def parse(cards_csv)
      CSV.parse(cards_csv.read.force_encoding("UTF-8"), headers: true)
    end

    def validate(csv)
      validate_headers(csv) ||
        CsvExamples.validate_headers(csv) ||
        validate_present(csv) ||
        validate_rows(csv) ||
        validate_unique_fronts(csv) ||
        validate_distractors_present(csv) ||
        CsvExamples.validate_pairs(csv)
    end

    def distractors_column?(csv)
      csv.headers.include?("distractors")
    end

    def rows(csv)
      columns = {
        distractors: distractors_column?(csv),
        examples: CsvExamples.present?(csv),
        reading: CsvReading.present?(csv),
      }
      csv.map { |row| row_content(row, columns) }
    end

    def validate_headers(csv)
      headers = csv.headers.map { |h| h.to_s.strip.downcase }
      return if headers.include?("front") && headers.include?("back")

      "must include 'front' and 'back' columns"
    end

    def validate_present(csv)
      return unless csv.empty?

      "must include at least one row"
    end

    def validate_unique_fronts(csv)
      fronts = csv.map { |row| row["front"].squish }
      duplicates = fronts.tally.select { |_, count| count > 1 }.keys
      return if duplicates.empty?

      "duplicate 'front' values: #{duplicates.join(", ")}"
    end

    private

    def row_content(row, columns)
      {
        front: row["front"].squish,
        back: row["back"].squish,
        category: row["category"].to_s.squish,
        distractors: columns[:distractors] ? parse_distractors(row) : [],
        **(columns[:examples] ? CsvExamples.attributes(row) : {}),
        **(columns[:reading] ? CsvReading.attributes(row) : {}),
      }
    end

    def validate_rows(csv)
      csv.each_with_index do |row, index|
        next if row["front"]&.squish.present? &&
          row["back"]&.squish.present?

        return "row #{index + 1} is missing a " \
               "'front' or 'back' value"
      end

      nil
    end

    def validate_distractors_present(csv)
      return unless distractors_column?(csv)

      csv.each_with_index do |row, index|
        next if parse_distractors(row).any?

        return "row #{index + 1} is missing a 'distractors' value"
      end

      nil
    end

    def parse_distractors(row)
      row["distractors"].to_s.split(";").map(&:squish).reject(&:empty?)
    end
  end
end
