# frozen_string_literal: true

require "rails_helper"

RSpec.describe ItemDistractor do
  it { is_expected.to belong_to(:item) }
  it { is_expected.to belong_to(:distractor_item).class_name("Item") }

  it do
    create(:item_distractor)

    expect(described_class.new)
      .to validate_uniqueness_of(:item_id).scoped_to(:distractor_item_id)
  end
end
