# frozen_string_literal: true

require "csv"

module Decks
  module Create
    def self.call(user:, name:, cards_csv:)
      deck = Deck.new(name:)
      csv = CSV.parse(cards_csv.read, headers: true)

      error = validate_csv(csv)
      if error
        deck.errors.add(:cards_csv, error)
        return Result.new(success: false, record: deck)
      end

      ActiveRecord::Base.transaction do
        deck.user = user
        return Result.new(success: false, record: deck) unless deck.save

        cards_data = collect_cards_data(csv)
        build_and_insert_cards(deck, cards_data)
      end

      Result.new(success: true, record: deck)
    end

    def self.validate_csv(csv)
      validate_csv_headers(csv) || validate_csv_rows(csv)
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

    def self.collect_cards_data(csv)
      cards_data = {}
      csv.each do |row|
        front = row["front"].squish
        back = row["back"].squish
        category = row["category"].to_s.squish

        cards_data[front] ||= { back: [], category: }
        cards_data[front][:back] += back.split(";").map(&:squish)
      end
      cards_data
    end

    def self.build_and_insert_cards(deck, cards_data)
      cards_attributes =
        cards_data.map do |front, data|
          card = deck.cards.build(front:)
          card.back = data[:back].uniq.join(";")
          card.category = data[:category]
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
