# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pairing do
  it { is_expected.to belong_to(:item) }
  it { is_expected.to belong_to(:paired_item).class_name("Item") }

  it do
    create(:pairing)

    expect(described_class.new)
      .to validate_uniqueness_of(:item_id).scoped_to(:paired_item_id)
  end
end
