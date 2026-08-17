# frozen_string_literal: true

FactoryBot.define do
  factory(:pairing) do
    transient do
      word_list { association(:word_list) }
    end

    item { association(:item, word_list:) }
    paired_item { association(:item, :back, word_list:) }
  end
end
