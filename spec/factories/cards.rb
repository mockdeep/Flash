# frozen_string_literal: true

# Language cards are thin item_id+progress anchors; their content lives on
# data_set items. The language factory accepts content as transient
# attributes and projects it into items after the card is created.
module FactoryCardContent
  NOTES = ["C", "D", "E", "F", "G", "A", "B"].freeze

  def self.project(card, attrs)
    content = {
      front: attrs.front,
      back: attrs.back,
      category: attrs.category,
      distractors: attrs.distractors,
      reading: attrs.reading,
      example_front: attrs.example_front,
      example_back: attrs.example_back,
    }
    DataSets::Projection.project(card, content)
  end
end

FactoryBot.define do
  # Flat-card families: content lives on the card's own columns.
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
      sequence(:back, 1) { |n| "#{FactoryCardContent::NOTES[n % 7]}3" }
      category { "Notes" }
    end
  end

  factory(:reading_card, class: "ReadingCard") do
    deck { association(:reading_deck) }
    item { association(:item, data_set: deck.data_set) }

    transient do
      sequence(:front, 100) { |n| "Card Front #{n}" }
      sequence(:back, 100) { |n| "Card Back #{n}" }
      category { "General" }
      distractors { [] }
      reading { nil }
      example_front { nil }
      example_back { nil }
    end

    after(:create) { |card, attrs| FactoryCardContent.project(card, attrs) }

    trait(:done) do
      correct_streak { deck.level }
    end
  end
end
