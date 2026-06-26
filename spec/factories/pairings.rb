# frozen_string_literal: true

FactoryBot.define do
  factory(:pairing) do
    transient do
      data_set { association(:data_set) }
    end

    item { association(:item, data_set:) }
    paired_item { association(:item, :back, data_set:) }
  end
end
