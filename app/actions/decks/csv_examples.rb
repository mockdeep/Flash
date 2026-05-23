# frozen_string_literal: true

module Decks
  module CsvExamples
    COLUMNS = ["example_front", "example_back"].freeze

    def self.present?(csv)
      (COLUMNS - csv.headers).empty?
    end

    def self.absent?(csv) = !present?(csv)

    def self.validate_headers(csv)
      present_count = (csv.headers & COLUMNS).length
      return if [0, COLUMNS.length].include?(present_count)

      "must include both 'example_front' and 'example_back' columns or neither"
    end

    def self.validate_pairs(csv)
      return if absent?(csv)

      csv.each_with_index do |row, index|
        front = row["example_front"].to_s.squish
        back = row["example_back"].to_s.squish
        next if front.empty? == back.empty?

        return "row #{index + 1} must include both " \
               "'example_front' and 'example_back' or neither"
      end

      nil
    end

    def self.attributes(row)
      {
        example_front: row["example_front"].to_s.squish.presence,
        example_back: row["example_back"].to_s.squish.presence,
      }
    end
  end
end
