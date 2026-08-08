# frozen_string_literal: true

module Decks
  # Outcome of a deck action: the (possibly unsaved) deck record plus, for
  # replace, a change summary.
  class Result
    attr_accessor :success, :record, :summary

    def initialize(success:, record:, summary: nil)
      self.success = success
      self.record = record
      self.summary = summary
    end

    def success?
      success
    end
  end
end
