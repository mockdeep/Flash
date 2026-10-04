# frozen_string_literal: true

module Llm
  # One question about a list of items, prompted by the asker under each
  # item's index. The rows of the answer's `list` come back keyed by that
  # index, so a row the model leaves out is simply absent. Nothing is asked
  # when there are no items.
  module AskEach
    def self.call(items, list:, prompt:, **)
      return {} if items.empty?

      answer = Llm.client.call(prompt: prompt.to_json, **)
      answer[list].index_by { |row| row["id"] }
    end
  end
end
