# frozen_string_literal: true

module Snippets
  # A language's system prompts for each step that asks a model, and the
  # categories its words are filed under.
  Prompts = Data.define(:segment, :propose, :judge, :categorize, :categories)
end
