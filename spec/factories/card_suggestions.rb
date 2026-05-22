# frozen_string_literal: true

FactoryBot.define do
  factory(:card_suggestion) do
    card
    user
    front { "Suggested front" }
    back { "Suggested back" }
    category { "General" }
    state { "pending" }
  end
end
