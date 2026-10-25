# frozen_string_literal: true

module Snippets
  # A language's system prompts for each step that asks a model.
  Prompts = Data.define(:segment, :propose, :judge, :categorize)
end
