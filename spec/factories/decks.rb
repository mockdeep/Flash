# frozen_string_literal: true

FactoryBot.define do
  factory(:deck, class: "BasicDeck") do
    transient do
      sequence(:name, 100) { |n| "Deck #{n}" }
      user { default_user }
    end

    data_set { association(:data_set, user:, name:) }
    study_goal { 50 }
    distractor_pool { "category" }
  end

  factory(:reading_deck, class: "ReadingDeck") do
    transient do
      sequence(:name, 100) { |n| "Reading Deck #{n}" }
      user { default_user }
      language { "zh" }
    end

    data_set { association(:language_data_set, user:, name:, language:) }
    study_goal { 50 }
    distractor_pool { "category" }
  end

  factory(:writing_deck, class: "WritingDeck") do
    transient do
      sequence(:name, 100) { |n| "Writing Deck #{n}" }
      user { default_user }
      language { "zh" }
    end

    data_set { association(:language_data_set, user:, name:, language:) }
    study_goal { 50 }
    distractor_pool { "category" }
  end

  factory(:music_deck, class: "MusicDeck") do
    transient do
      sequence(:name, 100) { |n| "Music Deck #{n}" }
      user { default_user }
    end

    data_set { association(:music_data_set, user:, name:) }
    study_goal { 50 }
    distractor_pool { "none" }
  end
end
