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

  it "allows a supported language or none" do
    expect(described_class.new).to validate_inclusion_of(:language)
      .in_array(described_class::LANGUAGES).allow_nil
  end

  describe "#detect_language!" do
    it "sets zh when an item contains Han characters" do
      data_set = create(:data_set)
      create(:item, data_set:, text: "你好")

      data_set.detect_language!

      expect(data_set.reload.language).to eq("zh")
    end

    it "leaves the language empty when no item contains Han characters" do
      data_set = create(:data_set)
      create(:item, data_set:, text: "hola")

      data_set.detect_language!

      expect(data_set.reload.language).to be_nil
    end
  end
end
