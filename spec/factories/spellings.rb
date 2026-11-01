# frozen_string_literal: true

FactoryBot.define do
  factory(:spelling) do
    entry
    sequence(:text) { |number| "spelling#{number}" }
  end
end
