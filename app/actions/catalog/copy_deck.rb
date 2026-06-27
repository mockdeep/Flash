# frozen_string_literal: true

module Catalog
  module CopyDeck
    def self.call(user:, deck:, card_limit: nil)
      new_deck = build_new_deck(user:, source: deck)

      ActiveRecord::Base.transaction do
        return Result.new(success: false, record: new_deck) unless new_deck.save

        copy_cards(new_deck, deck, card_limit)
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

    # Text decks store content in their data_set; music decks (no data_set)
    # still copy via the card columns.
    def self.copy_cards(new_deck, source, card_limit)
      if source.is_a?(TextDeck)
        DataSets::Projection.build(new_deck, copy_rows(source, card_limit))
      else
        copy_card_columns(new_deck, source, card_limit)
      end
    end

    def self.copy_rows(source, card_limit)
      copy_distractors = source.distractor_pool == "preset"
      source_cards(source, card_limit).map do |card|
        content_row(card, copy_distractors:)
      end
    end

    def self.content_row(card, copy_distractors:)
      content = CardContent.new(card)
      content.to_row.merge(
        distractors: copy_distractors ? content.distractors : [],
        source_card_id: card.id,
      )
    end

    def self.copy_card_columns(new_deck, source, card_limit)
      copy_distractors = source.distractor_pool == "preset"
      attributes =
        source_cards(source, card_limit).map do |card|
          card_attributes(new_deck, card, copy_distractors:)
        end
      Card.insert_all(attributes) if attributes.any?
    end

    def self.card_attributes(new_deck, card, copy_distractors:)
      new_card = card.class.new(
        deck: new_deck,
        source_card_id: card.id,
        **card.slice(
          :front, :back, :category, :example_front, :example_back, :reading
        ),
      )
      new_card.distractors = card.distractors if copy_distractors
      new_card.attributes.without("id", "created_at", "updated_at")
    end

    def self.source_cards(source, card_limit)
      scope = source.cards.includes(item: { pairings: :paired_item })
      card_limit ? scope.order(:id).limit(card_limit) : scope
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
