# frozen_string_literal: true

module Catalog
  module CopyDeck
    def self.call(user:, deck:, card_limit: nil)
      new_deck = build_new_deck(user:, source: deck)

      ActiveRecord::Base.transaction do
        return Result.new(success: false, record: new_deck) unless new_deck.save

        build_and_insert_cards(new_deck, deck, card_limit:)
      end

      Result.new(success: true, record: new_deck)
    end

    def self.build_new_deck(user:, source:)
      source.class.new(
        name: source.name,
        user:,
        study_goal: user.study_goal,
        distractor_pool: source.distractor_pool,
      )
    end

    def self.build_and_insert_cards(new_deck, source_deck, card_limit:)
      copy_distractors = source_deck.distractor_pool == "preset"
      cards_attributes =
        source_cards(source_deck, card_limit).map do |card|
          build_card_attributes(new_deck, card, copy_distractors:)
        end

      Card.insert_all(cards_attributes) if cards_attributes.any?
    end

    def self.source_cards(source_deck, card_limit)
      return source_deck.cards unless card_limit

      source_deck.cards.order(:id).limit(card_limit)
    end

    def self.build_card_attributes(new_deck, card, copy_distractors:)
      new_card = card.class.new(
        deck: new_deck,
        source_card_id: card.id,
        **card.slice(:front, :back, :category, :example_front, :example_back),
      )
      new_card.distractors = card.distractors if copy_distractors
      new_card.attributes.without("id", "created_at", "updated_at")
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
