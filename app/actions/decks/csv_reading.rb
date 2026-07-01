# frozen_string_literal: true

module Decks
  module CsvReading
    extend self

    COLUMN = "reading"

    def present?(csv)
      csv.headers.map { |h| h.to_s.strip.downcase }.include?(COLUMN)
    end

    def attributes(row)
      { reading: row[COLUMN].to_s.squish.presence }
    end
  end
end
