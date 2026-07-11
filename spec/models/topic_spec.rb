# frozen_string_literal: true

require "rails_helper"

RSpec.describe Topic do
  it { is_expected.to belong_to(:user).required }
  it { is_expected.to have_many(:data_sets).dependent(:nullify) }

  it { is_expected.to validate_presence_of(:name) }

  it "validates uniqueness of name scoped to user" do
    create(:topic)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  it "releases its data_sets when destroyed" do
    topic = create(:topic)
    data_set = create(:data_set, topic:)

    topic.destroy!

    expect(data_set.reload.topic).to be_nil
  end
end
