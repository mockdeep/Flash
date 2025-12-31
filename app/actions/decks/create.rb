# frozen_string_literal: true

require "csv"

module Decks
  module Create
    def self.call(user:, name:, cards_csv:)
      ActiveRecord::Base.transaction do
        deck = user.decks.build(name:)
        return Result.new(success: false, record: deck) unless deck.save

        import_cards(deck, cards_csv)
      end
    end

    def self.import_cards(deck, cards_csv)
      csv = CSV.parse(cards_csv.read, headers: true)
      cards_data = {}
      csv.each do |row|
        front = row["front"].squish
        back = row["back"].squish
        category = row["category"].squish

        cards_data[front] ||= { back: [], category: }
        cards_data[front][:back] += back.split(";").map(&:squish)
      end

      cards_attributes =
        cards_data.map do |front, data|
          card = deck.cards.build(front:)
          card.back = data[:back].uniq.join(";")
          card.category = data[:category]
          card.status = "pending"
          card.attributes.without("id", "created_at", "updated_at")
        end

      Card.insert_all(cards_attributes)
      Result.new(success: true, record: deck)
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
