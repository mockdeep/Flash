# frozen_string_literal: true

FactoryBot.define do
  factory(:word_list) do
    sequence(:name, 100) { |n| "Word List #{n}" }
    user { default_user }
    language { "zh" }
  end
end
