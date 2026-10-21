# frozen_string_literal: true

FactoryBot.define do
  factory(:snippet) do
    # A snippet reaches its list through its source; naming the list picks
    # (or makes) the source over it.
    transient { word_list { nil } }
    source do
      next association(:source) unless word_list

      word_list.source || association(:source, word_list:)
    end
    body { "我爱你。" }

    # Its one sentence holds no word, so nothing is left to resolve.
    trait(:finished) do
      after(:create) do |snippet|
        create(:snippet_sentence, snippet:, tokens: [{ "text" => "。" }])
      end
    end
  end

  factory(:snippet_sentence) do
    snippet
    source { snippet&.source || association(:source) }
    sequence(:position, 100)
    body { "我爱你。" }
  end

  # A source's title (or, given the role, its author), in no snippet.
  factory(:front_matter, class: "SnippetSentence") do
    source
    snippet { nil }
    role { "title" }
    sequence(:position)
    body { "春节" }
  end
end
