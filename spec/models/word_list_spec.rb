# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordList do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:sense_memberships).dependent(:destroy) }
  it { is_expected.to have_many(:senses).through(:sense_memberships) }
  it { is_expected.to have_many(:decks).dependent(:restrict_with_exception) }
  it { is_expected.to have_one(:source).dependent(:destroy) }
  it { is_expected.to have_many(:snippets).through(:source) }

  it { is_expected.to validate_presence_of(:name) }

  it "cannot be destroyed while a deck references it" do
    deck = create(:reading_deck)

    expect { deck.word_list.destroy! }
      .to raise_error(ActiveRecord::DeleteRestrictionError)
  end

  it "validates uniqueness of name scoped to user" do
    create(:word_list)

    expect(described_class.new)
      .to validate_uniqueness_of(:name).scoped_to(:user_id)
  end

  it "is private until made public" do
    expect(described_class.new.visibility).to eq("private")
  end

  it "allows only a known visibility" do
    expect(described_class.new)
      .to validate_inclusion_of(:visibility).in_array(["public", "private"])
  end

  def list_with_source(license:, snippet: :finished)
    source = create(:source, license:)
    create(:snippet, *snippet, source:)
    source.word_list.reload
  end

  it "can be made public with no source" do
    expect(create(:word_list)).to allow_value("public").for(:visibility)
  end

  it "can be made public with a shareable source and a finished snippet" do
    list = list_with_source(license: "public_domain")

    expect(list).to allow_value("public").for(:visibility)
  end

  it "cannot be made public while its source's license isn't shareable" do
    list = list_with_source(license: "all_rights_reserved")

    expect(list).not_to allow_value("public").for(:visibility)
  end

  it "cannot be made public before its source has a finished snippet" do
    list = list_with_source(license: "public_domain", snippet: [])

    expect(list).not_to allow_value("public").for(:visibility)
  end

  it "stays valid once public, whatever becomes of its source" do
    list = list_with_source(license: "public_domain")
    list.update!(visibility: "public")
    list.source.update!(license: "all_rights_reserved")

    expect(list.reload).to be_valid
  end

  it "can be made private again" do
    list = create(:word_list, visibility: "public")

    expect(list).to allow_value("private").for(:visibility)
  end

  describe "#publicly_visible?" do
    it "is true of a public list" do
      expect(described_class.new(visibility: "public")).to be_publicly_visible
    end

    it "is false of a private list" do
      expect(described_class.new).not_to be_publicly_visible
    end
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
      expect(described_class::LANGUAGES["pt"]).to eq("Portuguese")
    end

    it "names zh Mandarin" do
      expect(described_class::LANGUAGES["zh"]).to eq("Mandarin")
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
