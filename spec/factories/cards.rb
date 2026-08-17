# frozen_string_literal: true

# Language cards are thin item_id+progress anchors; their content lives on
# word_list items. The language factory takes content as transient attributes,
# builds the front item from them, and links the back side after create.
module FactoryCardContent
  NOTES = ["C", "D", "E", "F", "G", "A", "B"].freeze

  # Pairs the card's front item to one Back item per gloss and links any
  # distractors as unpaired decoys.
  def self.link_backs(card, attrs)
    glosses(attrs.back).each do |text|
      Pairing.create!(item: card.item, paired_item: back_item(card, text))
    end
    Array(attrs.distractors).each do |text|
      ItemDistractor.create!(
        item: card.item, distractor_item: back_item(card, text),
      )
    end
  end

  def self.back_item(card, text)
    card.deck.word_list.items.find_or_create_by!(side: "Back", text:)
  end

  def self.glosses(back)
    back.to_s.split(";").map(&:squish).compact_blank.uniq
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
    transient do
      sequence(:front, 100) { |n| "Card Front #{n}" }
      sequence(:back, 100) { |n| "Card Back #{n}" }
      category { "General" }
      distractors { [] }
      reading { nil }
      example_front { nil }
      example_back { nil }
    end

    deck { association(:reading_deck) }
    item do
      association(
        :item,
        word_list: deck.word_list,
        text: front,
        category:,
        reading:,
        example: example_front,
        paired_example: example_back,
      )
    end

    after(:create) { |card, attrs| FactoryCardContent.link_backs(card, attrs) }

    trait(:done) do
      correct_streak { deck.level }
    end
  end
end
