# frozen_string_literal: true

# A word as a language deck studies it. Building one puts the entry, its
# senses and their memberships into the deck's word_list - the example on
# each sense, each distractor remembered as a sibling entry the owner has
# confused it with, and any counters scored on every sense - and returns
# the deck's LanguageCard for it.
module FactoryLanguageCards
  Word = Struct.new(
    :deck,
    :front,
    :back,
    :reading,
    :category,
    :example_front,
    :example_back,
    :distractors,
    :correct_count,
    :correct_streak,
    :view_count,
  )

  def self.create(word)
    list = word.deck.word_list
    entry = entry_for(list, word)
    senses = glosses(word.back).map { |gloss| select(list, entry, gloss, word) }
    score(word, senses)
    word.distractors.each { |text| remember(word, senses, text) }
    word.deck.card(entry.id)
  end

  def self.entry_for(list, word)
    Entry.find_or_create_by!(
      language: list.language, headword: word.front, reading: word.reading,
    )
  end

  def self.select(list, entry, gloss, word)
    sense = Sense.find_or_create_by!(entry:, gloss:)
    list.sense_memberships.create!(
      sense:, position: next_position(list), category: word.category,
    )
    add_example(sense, word)
    sense
  end

  def self.next_position(list)
    (list.sense_memberships.maximum(:position) || 0) + 1
  end

  def self.add_example(sense, word)
    return if word.example_front.blank?

    sense.sense_examples.find_or_create_by!(sentence: word.example_front) do
      |example| example.translation = word.example_back
    end
  end

  def self.score(word, senses)
    counters = word.to_h.slice(:correct_count, :correct_streak, :view_count)
    return if counters.values.all?(&:zero?)

    senses.each do |sense|
      SkillScore.create!(
        user: word.deck.user, sense:, skill: word.deck.skill, **counters,
      )
    end
  end

  # A decoy is a sibling entry in the list (headword = the text) that every
  # member sense links to.
  def self.remember(word, senses, text)
    list = word.deck.word_list
    entry = Entry.find_or_create_by!(language: list.language, headword: text)
    glosses(text).each do |gloss|
      decoy = Sense.find_or_create_by!(entry:, gloss:)
      list.sense_memberships.find_or_create_by!(sense: decoy) do |membership|
        membership.position = next_position(list)
      end
      senses.each { |sense| link(word.deck.user, sense, decoy) }
    end
  end

  def self.link(user, sense, decoy)
    SenseDistractor.create!(
      user:,
      sense:,
      distractor_sense: decoy,
      miss_count: 1,
      last_missed_at: Time.current,
    )
  end

  def self.glosses(back)
    back.to_s.split(";").map(&:squish).compact_blank.uniq
  end
end

FactoryBot.define do
  factory(:language_card, class: "LanguageCard") do
    skip_create
    initialize_with { FactoryLanguageCards.create(FactoryLanguageCards::Word.new(**attributes)) }

    deck { association(:reading_deck) }
    sequence(:front, 100) { |n| "Word #{n}" }
    sequence(:back, 100) { |n| "Gloss #{n}" }
    reading { nil }
    category { "General" }
    example_front { nil }
    example_back { nil }
    distractors { [] }
    correct_count { 0 }
    correct_streak { 0 }
    view_count { 0 }

    trait(:done) do
      correct_streak { deck.level }
    end
  end
end
