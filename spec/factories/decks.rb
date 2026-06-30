# frozen_string_literal: true

FactoryBot.define do
  factory(:deck, class: "TextDeck") do
    transient do
      sequence(:name, 100) { |n| "Deck #{n}" }
      user { default_user }
    end

    data_set { association(:data_set, user:, name:) }
    study_goal { 50 }
    distractor_pool { "category" }
  end

  factory(:music_deck, class: "MusicDeck") do
    transient do
      sequence(:name, 100) { |n| "Music Deck #{n}" }
      user { default_user }
    end

    data_set { association(:data_set, user:, name:) }
    study_goal { 50 }
    distractor_pool { "none" }
  end
end
