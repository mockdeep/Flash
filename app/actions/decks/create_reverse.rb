# frozen_string_literal: true

module Decks
  # Spins a reverse deck over an existing deck's data_set: the same content
  # studied with prompts and answers swapped. It shares the source data_set (no
  # re-upload) and generates one card per paired answer item.
  module CreateReverse
    extend self

    def call(source:)
      return failure(source) unless creatable?(source)

      deck = build_deck(source)
      ActiveRecord::Base.transaction do
        deck.save!
        DataSets::Projection.reconcile_deck(deck, {})
      end
      Result.new(success: true, record: deck)
    end

    private

    def creatable?(source)
      source.reversible? && !source.reverse_present?
    end

    def build_deck(source)
      WritingDeck.new(
        user: source.user,
        study_goal: source.study_goal,
        distractor_pool: "category",
        data_set: source.data_set,
      )
    end

    def failure(source)
      Result.new(success: false, record: source)
    end

    class Result
      attr_accessor :success, :record

      def initialize(success:, record:)
        self.success = success
        self.record = record
      end

      def success? = success
    end
  end
end
