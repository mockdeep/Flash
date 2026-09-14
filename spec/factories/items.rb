# frozen_string_literal: true

FactoryBot.define do
  factory(:item) do
    word_list
    side { "Front" }
    sequence(:text, 100) { |n| "Item #{n}" }
    reading { nil }

    entry do
      language = word_list.language
      Entry.find_or_create_by!(language:, headword: text, reading:)
    end
  end
end
