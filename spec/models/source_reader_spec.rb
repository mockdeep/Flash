# frozen_string_literal: true

require "rails_helper"

RSpec.describe SourceReader do
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:user) }

  it do
    create(:source_reader)

    expect(build(:source_reader))
      .to validate_uniqueness_of(:user_id).scoped_to(:source_id)
  end

  it "is removed with its source" do
    reader = create(:source_reader)

    expect { reader.source.destroy! }.to delete_record(reader)
  end

  it "is removed with its user" do
    reader = create(:source_reader)

    expect { reader.user.destroy! }.to delete_record(reader)
  end
end
