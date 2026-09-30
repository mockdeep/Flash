# frozen_string_literal: true

module Matchers
  class MakeDatabaseQueries
    IGNORED_NAMES = ["SCHEMA", "TRANSACTION"].freeze

    attr_reader :queries

    def supports_block_expectations?
      true
    end

    def matches?(event_proc)
      @queries = []
      ActiveSupport::Notifications
        .subscribed(method(:record), "sql.active_record", &event_proc)

      queries.any?
    end

    def failure_message
      "expected the block to make database queries but it made none"
    end

    def failure_message_when_negated
      <<~MESSAGE
        expected the block to make no database queries but it made #{queries.size}:
        #{queries.join("\n")}
      MESSAGE
    end

    private

    def record(*, payload)
      return if payload[:cached] || IGNORED_NAMES.include?(payload[:name])

      queries << payload[:sql]
    end
  end
end
