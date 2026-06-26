# frozen_string_literal: true

FactoryBot.define do
  factory(:data_set) do
    sequence(:name, 100) { |n| "Data Set #{n}" }
    user { default_user }
  end
end
