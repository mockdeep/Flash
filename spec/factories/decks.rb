# frozen_string_literal: true

FactoryBot.define do
  factory(:deck, class: "BasicDeck") do
    sequence(:name, 100) { |n| "Deck #{n}" }
    user { default_user }
    study_goal { 50 }
    distractor_pool { "category" }
  end

  factory(:reading_deck, class: "ReadingDeck") do
    transient do
      sequence(:name, 100) { |n| "Reading Deck #{n}" }
      language { "zh" }
    end

    user { default_user }
    data_set { association(:language_data_set, user:, name:, language:) }
    study_goal { 50 }
    distractor_pool { "category" }
  end

  factory(:music_deck, class: "MusicDeck") do
    sequence(:name, 100) { |n| "Music Deck #{n}" }
    user { default_user }
    study_goal { 50 }
    distractor_pool { "none" }
  end
end
