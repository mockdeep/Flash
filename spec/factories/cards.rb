# frozen_string_literal: true

# Cards are thin item_id+progress anchors; their content lives on data_set
# items. The factory accepts content as transient attributes and projects it
# into items after the card is created.
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
  # Abstract: create cards through the typed sub-factories below so the card
  # class matches the deck's card_type.
  factory(:card, class: "Card") do
    deck { default_deck }
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

    factory(:basic_card, class: "BasicCard")

    factory(:reading_card, class: "ReadingCard") do
      deck { association(:reading_deck) }
    end

    factory(:music_card, class: "MusicCard") do
      deck { default_music_deck }

      transient do
        sequence(:front, 100) { |n| "Music Card #{n}" }
        sequence(:back, 1) { |n| "#{FactoryCardContent::NOTES[n % 7]}3" }
        category { "Notes" }
      end
    end
  end
end
