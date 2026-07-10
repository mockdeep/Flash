# frozen_string_literal: true

FactoryBot.define do
  factory(:data_set, class: "BasicDataSet") do
    sequence(:name, 100) { |n| "Data Set #{n}" }
    user { default_user }

    factory(:language_data_set, class: "LanguageDataSet") do
      language { "zh" }
    end

    factory(:music_data_set, class: "MusicDataSet")
  end
end
