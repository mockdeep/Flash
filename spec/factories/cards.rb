# frozen_string_literal: true

# Language cards are thin item_id+progress anchors. The language factory
# takes content as transient attributes, builds the front item (and so the
# entry) from them, and selects the back side into the deck's word_list as
# senses after create.
module FactoryCardContent
  NOTES = ["C", "D", "E", "F", "G", "A", "B"].freeze

  # Selects one sense per gloss into the list, in gloss order, filed under
  # the card's category and carrying its example; remembers each distractor
  # as a sibling entry (headword = the text, no card) the deck's owner has
  # confused with this one.
  def self.link_backs(card, attrs)
    senses =
      glosses(attrs.back).map do |gloss|
        select_sense(card.deck.word_list, card.entry, gloss, attrs)
      end
    score(card, senses)
    Array(attrs.distractors).each { |text| remember_decoy(card, text) }
  end

  def self.select_sense(list, entry, gloss, attrs)
    sense = Sense.find_or_create_by!(entry:, gloss:)
    list.sense_memberships.create!(
      sense:, position: next_position(list), category: attrs.category,
    )
    add_example(sense, attrs)
    sense
  end

  # A card created with progress scores its senses too, as the backfill did.
  def self.score(card, senses)
    counters = card.slice(:correct_count, :correct_streak, :view_count)
    return if counters.values.all?(&:zero?)

    senses.each do |sense|
      SkillScore.create!(
        user: card.deck.user, sense:, skill: card.deck.skill, **counters,
      )
    end
  end

  def self.next_position(list)
    (list.sense_memberships.maximum(:position) || 0) + 1
  end

  def self.remember_decoy(card, text)
    list = card.deck.word_list
    entry = Entry.find_or_create_by!(language: list.language, headword: text)
    glosses(text).each do |gloss|
      sense = Sense.find_or_create_by!(entry:, gloss:)
      list.sense_memberships.find_or_create_by!(sense:) do |membership|
        membership.position = next_position(list)
      end
      link_decoy(card, sense)
    end
  end

  def self.link_decoy(card, decoy)
    card.deck.word_list.senses.where(entry: card.entry).find_each do |sense|
      SenseDistractor.create!(
        user: card.deck.user,
        sense:,
        distractor_sense: decoy,
        miss_count: 1,
        last_missed_at: Time.current,
      )
    end
  end

  def self.add_example(sense, attrs)
    return if attrs.example_front.blank?

    sense.sense_examples.find_or_create_by!(sentence: attrs.example_front) do
      |example| example.translation = attrs.example_back
    end
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
