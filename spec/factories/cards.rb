# frozen_string_literal: true

FactoryBot.define do
  factory(:card, class: "TextCard") do
    deck { default_deck }

    sequence(:front, 100) { |n| "Card Front #{n}" }
    sequence(:back, 100) { |n| "Card Back #{n}" }
    category { "General" }

    trait(:done) do
      correct_streak { deck.level }
    end
  end

  factory(:music_card, class: "MusicCard") do
    deck { default_music_deck }

    sequence(:front, 100) { |n| "Music Card #{n}" }
    sequence(:back, 1) { |n| "#{["C", "D", "E", "F", "G", "A", "B"][n % 7]}3" }
    category { "Notes" }
  end
end
