# frozen_string_literal: true

require "rails_helper"

RSpec.describe Entry do
  it { is_expected.to have_many(:items).dependent(:restrict_with_exception) }

  it { is_expected.to validate_presence_of(:headword) }

  it "allows a known language" do
    expect(described_class.new).to allow_value("zh").for(:language)
  end

  it "rejects a missing or unknown language" do
    expect(described_class.new).not_to allow_value(nil, "xx").for(:language)
  end

  it "is unique on headword within a language and reading" do
    create(:entry, headword: "过", reading: "guò")

    expect(build(:entry, headword: "过", reading: "guò")).not_to be_valid
  end

  it "lets the same headword carry another reading" do
    create(:entry, headword: "过", reading: "guò")

    expect(build(:entry, headword: "过", reading: "guo")).to be_valid
  end

  it "cannot be destroyed while an item points at it" do
    item = create(:item)

    expect { item.entry.destroy! }
      .to raise_error(ActiveRecord::DeleteRestrictionError)
  end
end
