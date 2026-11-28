# frozen_string_literal: true

FactoryBot.define do
  factory(:source) do
    word_list
    sequence(:title, 100) { |n| "Source #{n}" }
  end

  factory(:source_listing) do
    source
  end

  factory(:source_reader) do
    source
    user
  end

  factory(:reading_place) do
    user
    snippet_sentence
    source { snippet_sentence.source }
    token_index { 0 }
  end
end
