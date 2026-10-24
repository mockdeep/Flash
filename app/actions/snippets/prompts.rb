# frozen_string_literal: true

module Snippets
  # A language's system prompts for each step that asks a model, and the
  # categories its words are filed under. `refine` holds the rules the
  # compendium refiner adds to its own.
  Prompts = Data.define(
    :segment, :propose, :judge, :categorize, :categories, :refine
  )
end
