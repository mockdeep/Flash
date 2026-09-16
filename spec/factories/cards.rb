# frozen_string_literal: true

# Flat-card families: content lives on the card's own columns. Language
# decks have no card rows; see the :word factory.
FactoryBot.define do
  factory(:basic_card, class: "BasicCard") do
    deck { default_deck }
    sequence(:front, 100) { |n| "Card Front #{n}" }
    sequence(:back, 100) { |n| "Card Back #{n}" }
    category { "General" }

    transient do
      distractors { [] }
    end

    after(:create) do |card, attrs|
      attrs.distractors.each { |text| card.card_distractors.create!(text:) }
    end

    trait(:done) do
      correct_streak { deck.level }
    end

    factory(:music_card, class: "MusicCard") do
      deck { default_music_deck }
      sequence(:front, 100) { |n| "Music Card #{n}" }
      sequence(:back, 1) { |n| "#{"CDEFGAB"[n % 7]}3" }
      category { "Notes" }
    end
  end
end
