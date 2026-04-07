# frozen_string_literal: true

FactoryBot.define do
  factory(:card) do
    deck { default_deck }

    sequence(:front, 100) { |n| "Card Front #{n}" }
    sequence(:back, 100) { |n| "Card Back #{n}" }
    category { "General" }

    trait(:done) do
      correct_streak { deck.level }
    end
  end
end
