# frozen_string_literal: true

require "rails_helper"

RSpec.describe Source do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to have_many(:snippets).dependent(:destroy) }
  it { is_expected.to have_many(:readers).dependent(:delete_all) }

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

  it "accepts a Portuguese list" do
    source = build(:source, word_list: build(:word_list, language: "pt"))

    expect(source).to be_valid
  end

  it "rejects a list in another language" do
    source = build(:source, word_list: build(:word_list, language: "ja"))

    expect(source).not_to be_valid
  end

  it "orders its snippets oldest first" do
    source = create(:source)
    word_list = source.word_list
    first = create(:snippet, word_list:, created_at: 1.day.ago)
    second = create(:snippet, word_list:, created_at: 2.days.ago)

    expect(source.snippets).to eq([first, second])
  end

  describe "#readable_by?" do
    it "is true for the list's owner" do
      source = build(:source)

      expect(source.readable_by?(source.word_list.user)).to be(true)
    end

    it "is true for anyone when it is shareable" do
      source = build(:source, license: "cc_by_sa")

      expect(source.readable_by?(create(:user))).to be(true)
    end

    it "is true for a reader let in" do
      reader = create(:source_reader)

      expect(reader.source.readable_by?(reader.user)).to be(true)
    end

    it "is false for anyone else when it is not shareable" do
      expect(build(:source).readable_by?(create(:user))).to be(false)
    end
  end

  describe "#status" do
    def source_with(*traits)
      source = create(:source)
      traits.each do |trait|
        create(:snippet, *trait, word_list: source.word_list)
      end
      source
    end

    it "is new without snippets" do
      expect(source_with.status).to eq(:new)
    end

    it "is new while every snippet is" do
      expect(source_with([], []).status).to eq(:new)
    end

    it "is in progress while its snippets differ" do
      expect(source_with([:finished], []).status).to eq(:in_progress)
    end

    it "is finished once every snippet is" do
      expect(source_with([:finished]).status).to eq(:finished)
    end

    it "is in progress while its front matter differs from its snippets" do
      source = source_with([:finished])
      create(:front_matter, source:)

      expect(source.status).to eq(:in_progress)
    end
  end

  describe "#title_paragraph" do
    it "is the title with its sentence" do
      source = create(:source, title: "春节")
      sentence = create(:front_matter, source:, body: "春节")

      paragraph = source.title_paragraph
      expect([paragraph.text, paragraph.sentences]).to eq(["春节", [sentence]])
    end
  end

  describe "#author_paragraph" do
    it "is the author with its sentence" do
      source = create(:source, author: "鲁迅")
      create(:front_matter, source:)
      sentence = create(:front_matter, source:, role: "author", body: "鲁迅")

      paragraph = source.author_paragraph
      expect([paragraph.text, paragraph.sentences]).to eq(["鲁迅", [sentence]])
    end
  end

  describe "#studyable?" do
    it "is true once a snippet is finished" do
      snippet = create(:snippet, :finished)

      expect(snippet.source).to be_studyable
    end

    it "is false before any snippet is finished" do
      snippet = create(:snippet)

      expect(snippet.source).not_to be_studyable
    end
  end

  describe "#license_name" do
    it "names the license" do
      expect(build(:source, license: "cc_by_sa").license_name)
        .to eq("CC BY-SA 4.0")
    end
  end

  describe "#license_url" do
    it "links to the license's terms" do
      expect(build(:source, license: "cc_by_sa").license_url)
        .to eq("https://creativecommons.org/licenses/by-sa/4.0/")
    end

    it "is nil for a license without terms to link" do
      expect(build(:source, license: "public_domain").license_url).to be_nil
    end
  end

  describe "#shareable?" do
    it "is true for a license that lets others read it" do
      expect(build(:source, license: "public_domain")).to be_shareable
    end

    it "is false for all rights reserved" do
      expect(build(:source)).not_to be_shareable
    end
  end
end
