# frozen_string_literal: true

module Catalog
  module CopyDeck
    def self.call(user:, deck:)
      new_deck = Deck.new(name: deck.name, user:)

      ActiveRecord::Base.transaction do
        return Result.new(success: false, record: new_deck) unless new_deck.save

        build_and_insert_cards(new_deck, deck)
      end

      Result.new(success: true, record: new_deck)
    end

    def self.build_and_insert_cards(new_deck, source_deck)
      cards_attributes =
        source_deck.cards.map do |card|
          new_card = new_deck.cards.build(front: card.front)
          new_card.back = card.back
          new_card.category = card.category
          new_card.status = "pending"
          new_card.attributes.without("id", "created_at", "updated_at")
        end

      Card.insert_all(cards_attributes) if cards_attributes.any?
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
