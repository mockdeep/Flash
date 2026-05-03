# frozen_string_literal: true

FactoryBot.define do
  factory(:deck, class: "TextDeck") do
    sequence(:name, 100) { |n| "Deck #{n}" }
    user { default_user }
    study_goal { 50 }
    distractor_pool { "category" }

    trait(:demo) do
      visibility { "demo" }
    end
  end

  factory(:music_deck, class: "MusicDeck") do
    sequence(:name, 100) { |n| "Music Deck #{n}" }
    user { default_user }
    study_goal { 50 }
    distractor_pool { "none" }
  end
end
