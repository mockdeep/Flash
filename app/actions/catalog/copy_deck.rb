# frozen_string_literal: true

module Catalog
  module CopyDeck
    extend self

    def call(user:, deck:, card_limit: nil)
      new_deck = build_new_deck(user:, source: deck)

      ActiveRecord::Base.transaction do
        return Result.new(success: false, record: new_deck) unless new_deck.save

        DataSets::Projection.build(new_deck, copy_rows(deck, card_limit))
      end

      Result.new(success: true, record: new_deck)
    end

    private

    def build_new_deck(user:, source:)
      source.class.new(
        study_goal: user.study_goal,
        distractor_pool: source.distractor_pool,
        data_set: DataSet.new(user:, name: source.name),
      )
    end

    def copy_rows(source, card_limit)
      copy_distractors = source.distractor_pool == "preset"
      source_cards(source, card_limit).map do |card|
        content_row(card, copy_distractors:)
      end
    end

    def content_row(card, copy_distractors:)
      card.to_row.merge(
        distractors: copy_distractors ? card.distractors : [],
        source_card_id: card.id,
      )
    end

    def source_cards(source, card_limit)
      scope = source.cards
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
