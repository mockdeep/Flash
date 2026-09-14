# frozen_string_literal: true

FactoryBot.define do
  factory(:sense) do
    entry
    sequence(:gloss, 100) { |n| "Gloss #{n}" }
  end

  factory(:sense_membership) do
    sense
    word_list
    position { 1 }
  end

  factory(:sense_example) do
    sense
    sequence(:sentence, 100) { |n| "Sentence #{n}" }
  end
end
