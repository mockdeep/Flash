# frozen_string_literal: true

FactoryBot.define do
  factory(:source) do
    word_list
    sequence(:title, 100) { |n| "Source #{n}" }
  end
end
