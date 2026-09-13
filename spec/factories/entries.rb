# frozen_string_literal: true

FactoryBot.define do
  factory(:entry) do
    language { "zh" }
    sequence(:headword, 100) { |n| "Entry #{n}" }
  end
end
