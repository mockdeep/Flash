# frozen_string_literal: true

FactoryBot.define do
  factory(:data_set, aliases: [:language_data_set], class: "LanguageDataSet") do
    sequence(:name, 100) { |n| "Data Set #{n}" }
    user { default_user }
    language { "zh" }
  end
end
