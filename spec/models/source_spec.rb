# frozen_string_literal: true

require "rails_helper"

RSpec.describe Source do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to have_many(:snippets).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:word_list) }
  it { is_expected.to validate_presence_of(:title) }
  it { expect(create(:source)).to validate_uniqueness_of(:word_list_id) }

  it do
    expect(build(:source)).to validate_inclusion_of(:license)
      .in_array(described_class::LICENSES.keys)
  end

  it { is_expected.to allow_value("https://zh.wikipedia.org/").for(:source_url) }
  it { is_expected.to allow_value("").for(:source_url) }
  it { is_expected.not_to allow_value("zh.wikipedia.org").for(:source_url) }

  it "shares with nobody by default" do
    expect(described_class.new.license).to eq("all_rights_reserved")
  end

  it "is removed with its word_list" do
    source = create(:source)

    expect { source.word_list.destroy! }.to delete_record(source)
  end
end
