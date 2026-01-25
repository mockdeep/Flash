# frozen_string_literal: true

FactoryBot.define do
  factory(:card) do
    deck { default_deck }

    sequence(:front, 100) { |n| "Card Front #{n}" }
    sequence(:back, 100) { |n| "Card Back #{n}" }
    category { "General" }
    status { "pending" }

    trait(:active) do
      status { "active" }
    end

    trait(:done) do
      status { "done" }
    end

    trait(:pending) do
      status { "pending" }
    end
  end
end
