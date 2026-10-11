# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetReader do
  it { is_expected.to belong_to(:snippet) }
  it { is_expected.to belong_to(:user) }

  it do
    create(:snippet_reader)

    expect(build(:snippet_reader))
      .to validate_uniqueness_of(:user_id).scoped_to(:snippet_id)
  end

  it "is removed with its snippet" do
    reader = create(:snippet_reader)

    expect { reader.snippet.destroy! }.to delete_record(reader)
  end

  it "is removed with its user" do
    reader = create(:snippet_reader)

    expect { reader.user.destroy! }.to delete_record(reader)
  end
end
