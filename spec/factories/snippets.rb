# frozen_string_literal: true

FactoryBot.define do
  factory(:snippet) do
    word_list
    sequence(:title, 100) { |n| "Snippet #{n}" }
    body { "我爱你。" }
  end

  factory(:snippet_sentence) do
    snippet
    sequence(:position, 100)
    body { "我爱你。" }
  end
end
