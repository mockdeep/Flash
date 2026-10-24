# frozen_string_literal: true

require "rails_helper"

RSpec.describe Entry do
  it { is_expected.to have_many(:senses).dependent(:restrict_with_exception) }

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

  it "keeps one entry for a headword without a reading" do
    create(:entry, language: "pt", headword: "casa", reading: nil)

    expect(build(:entry, language: "pt", headword: "casa", reading: nil))
      .not_to be_valid
  end

  it "lets the same headword carry another article" do
    create(:entry, language: "pt", headword: "capital", article: "o")

    expect(build(:entry, language: "pt", headword: "capital", article: "a"))
      .to be_valid
  end

  it "lets the same headword carry another reading" do
    create(:entry, headword: "过", reading: "guò")

    expect(build(:entry, headword: "过", reading: "guo")).to be_valid
  end

  describe ".in_review_order" do
    it "puts the least recently reviewed first" do
      recent = create(:entry, reviewed_at: 1.day.ago)
      older = create(:entry, reviewed_at: 2.days.ago)

      expect(described_class.in_review_order).to eq([older, recent])
    end

    it "puts never-reviewed entries before reviewed ones" do
      reviewed = create(:entry, reviewed_at: 2.days.ago)
      unreviewed = create(:entry)

      expect(described_class.in_review_order).to eq([unreviewed, reviewed])
    end

    it "puts an entry a list holds ahead of an unused one" do
      unused = create(:entry)
      listed = create(:sense_membership).sense.entry

      expect(described_class.in_review_order).to eq([listed, unused])
    end

    it "puts an entry a snippet uses ahead of an unused one" do
      unused = create(:entry)
      sense = create(:sense)
      create(:snippet_sentence, tokens: [{ text: "爱", sense_id: sense.id }])

      expect(described_class.in_review_order).to eq([sense.entry, unused])
    end

    it "breaks remaining ties by id" do
      first = create(:entry)
      second = create(:entry)

      expect(described_class.in_review_order).to eq([first, second])
    end
  end

  describe "#term" do
    it "puts a noun's article before its headword" do
      entry = build(:entry, headword: "casa", article: "a")

      expect(entry.term).to eq("a casa")
    end

    it "is the headword alone without an article" do
      expect(build(:entry, headword: "爱").term).to eq("爱")
    end
  end
end
