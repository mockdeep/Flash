# frozen_string_literal: true

FactoryBot.define do
  factory(:item) do
    word_list
    side { "Front" }
    sequence(:text, 100) { |n| "Item #{n}" }

    trait(:back) do
      side { "Back" }
    end
  end
end
