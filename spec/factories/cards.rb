# frozen_string_literal: true

# Language cards are thin item_id+progress anchors. The language factory
# takes content as transient attributes, builds the front item (and so the
# entry) from them, and selects the back side into the deck's word_list as
# senses after create.
module FactoryCardContent
  NOTES = ["C", "D", "E", "F", "G", "A", "B"].freeze

  # Selects one sense per gloss into the list, in gloss order, filed under
  # the card's category and carrying its example; links any distractors as
  # decoy Back items.
  def self.link_backs(card, attrs)
    glosses(attrs.back).each { |text| select_sense(card, text, attrs) }
    Array(attrs.distractors).each do |text|
      ItemDistractor.create!(
        item: card.item, distractor_item: back_item(card, text),
      )
    end
  end

  def self.select_sense(card, gloss, attrs)
    list = card.deck.word_list
    sense = Sense.find_or_create_by!(entry: card.entry, gloss:)
    position = (list.sense_memberships.maximum(:position) || 0) + 1
    list.sense_memberships.create!(sense:, position:, category: attrs.category)
    add_example(sense, attrs)
  end

  def self.add_example(sense, attrs)
    return if attrs.example_front.blank?

    sense.sense_examples.find_or_create_by!(sentence: attrs.example_front) do
      |example| example.translation = attrs.example_back
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
      association(:item, word_list: deck.word_list, text: front, reading:)
    end

    after(:create) { |card, attrs| FactoryCardContent.link_backs(card, attrs) }

    trait(:done) do
      correct_streak { deck.level }
    end
  end
end
