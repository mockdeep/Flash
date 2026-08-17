# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordList do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:items).dependent(:destroy) }
  it { is_expected.to have_many(:decks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }

  it "validates uniqueness of name scoped to user" do
    create(:word_list)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  it "requires a language" do
    expect(described_class.new).not_to allow_value(nil).for(:language)
  end

  it "allows any ISO 639 language code" do
    expect(described_class.new).to allow_value("zh", "tlh").for(:language)
  end

  it "rejects codes outside the registry and non-shortest forms" do
    expect(described_class.new)
      .not_to allow_value("xx", "zho", "Spanish").for(:language)
  end

  describe "LANGUAGES" do
    it "keys each language by its shortest available code" do
      expect(described_class::LANGUAGES["zh"]).to eq("Chinese")
    end

    it "includes languages that only have a three-letter code" do
      expect(described_class::LANGUAGES["tlh"]).to eq("Klingon")
    end

    it "omits collective language families" do
      expect(described_class::LANGUAGES).not_to have_key("afa")
    end

    it "omits special-purpose codes" do
      expect(described_class::LANGUAGES.keys)
        .not_to include("und", "zxx", "mul", "mis")
    end
  end
end
