# frozen_string_literal: true

FactoryBot.define do
  factory(:word_list) do
    sequence(:name, 100) { |n| "Word List #{n}" }
    user { default_user }
    language { "zh" }
  end

  # The linked list is made second, so its id is the higher of the two.
  factory(:word_list_link) do
    word_list
    linked_word_list { association(:word_list) }
    strength { 0.5 }
  end
end
