# frozen_string_literal: true

FactoryBot.define do
  factory(:item_distractor) do
    transient do
      word_list { association(:word_list) }
    end

    item { association(:item, word_list:) }
    distractor_item { association(:item, :back, word_list:) }
  end
end
