# frozen_string_literal: true

FactoryBot.define do
  factory(:topic) do
    sequence(:name, 100) { |n| "Topic #{n}" }
    user { default_user }
  end
end
