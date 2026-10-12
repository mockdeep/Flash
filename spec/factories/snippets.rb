# frozen_string_literal: true

FactoryBot.define do
  factory(:snippet) do
    word_list
    source { word_list.source || association(:source, word_list:) }
    body { "我爱你。" }

    # Its one sentence holds no word, so nothing is left to resolve.
    trait(:finished) do
      after(:create) do |snippet|
        create(:snippet_sentence, snippet:, tokens: [{ "text" => "。" }])
      end
    end
  end

  factory(:snippet_reader) do
    snippet
    user
  end

  factory(:snippet_sentence) do
    snippet
    sequence(:position, 100)
    body { "我爱你。" }
  end
end
