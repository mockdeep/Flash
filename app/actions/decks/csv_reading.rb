# frozen_string_literal: true

module Decks
  module CsvReading
    COLUMN = "reading"

    def self.present?(csv)
      csv.headers.map { |h| h.to_s.strip.downcase }.include?(COLUMN)
    end

    def self.attributes(row)
      { reading: row[COLUMN].to_s.squish.presence }
    end
  end
end
