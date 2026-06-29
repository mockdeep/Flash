# frozen_string_literal: true

module Decks
  # Spins a reverse deck over an existing deck's data_set: the same content
  # studied with prompts and answers swapped. It shares the source data_set (no
  # re-upload) and generates one card per paired answer item.
  module CreateReverse
    def self.call(source:)
      return failure(source) unless creatable?(source)

      deck = build_deck(source)
      ActiveRecord::Base.transaction do
        deck.save!
        DataSets::Projection.reconcile_deck(deck, {})
      end
      Result.new(success: true, record: deck)
    end

    def self.creatable?(source)
      source.reversible? && source.data_set && !source.reverse_present?
    end

    def self.build_deck(source)
      ReverseTextDeck.new(
        user: source.user,
        name: available_name(source),
        study_goal: source.study_goal,
        distractor_pool: "category",
        data_set: source.data_set,
      )
    end

    # "<name> (reversed)", suffixed with a number if that name is taken (deck
    # names are unique per user).
    def self.available_name(source)
      base = "#{source.name} (reversed)"
      return base unless taken?(source.user, base)

      (2..).lazy.map { |n| "#{base} #{n}" }
        .find { |name| !taken?(source.user, name) }
    end

    def self.taken?(user, name)
      user.decks.exists?(name:)
    end

    def self.failure(source)
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
