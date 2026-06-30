# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataSet do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:items).dependent(:destroy) }
  it { is_expected.to have_many(:decks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }

  it "validates uniqueness of name scoped to user" do
    create(:data_set)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
  end
end
