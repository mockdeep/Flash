# frozen_string_literal: true

FactoryBot.define do
  factory(:deck) do
    sequence(:name, 100) { |n| "Deck #{n}" }
    user { default_user }

    trait(:demo) do
      visibility { "demo" }
    end
  end
end
