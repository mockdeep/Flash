# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippet do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to have_many(:sentences).dependent(:delete_all) }
  it { is_expected.to have_many(:readers).dependent(:delete_all) }

  it { is_expected.to validate_presence_of(:word_list) }
  it { is_expected.to validate_presence_of(:source) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_length_of(:body).is_at_most(20_000) }

  it "orders its sentences by position" do
    snippet = create(:snippet)
    second = create(:snippet_sentence, snippet:, position: 2)
    first = create(:snippet_sentence, snippet:, position: 1)

    expect(snippet.sentences).to eq([first, second])
  end

  it "is removed with its word_list" do
    snippet = create(:snippet)

    expect { snippet.word_list.destroy! }.to delete_record(snippet)
  end

  describe "#status" do
    def snippet_with(*token_lists)
      snippet = create(:snippet)
      token_lists.each { |tokens| create(:snippet_sentence, snippet:, tokens:) }
      snippet
    end

    it "is new without sentences" do
      expect(snippet_with.status).to eq(:new)
    end

    it "is new before any sentence is segmented" do
      expect(snippet_with([], []).status).to eq(:new)
    end

    it "is in progress once a sentence is segmented" do
      expect(snippet_with([{ "text" => "我" }], []).status).to eq(:in_progress)
    end

    it "is finished once every sentence is" do
      tokens = [{ "text" => "我", "sense_id" => 1 }]

      expect(snippet_with(tokens).status).to eq(:finished)
    end
  end

  describe "#title" do
    it "joins the source's title and the heading" do
      source = build(:source, title: "春节")

      expect(build(:snippet, source:, heading: "习俗").title).to eq("春节 · 习俗")
    end

    it "is the source's title without a heading" do
      source = build(:source, title: "春节")

      expect(build(:snippet, source:).title).to eq("春节")
    end
  end

  describe "#readable_by?" do
    it "is true for the list's owner" do
      snippet = build(:snippet)

      expect(snippet.readable_by?(snippet.word_list.user)).to be(true)
    end

    it "is true for anyone when the source is shareable" do
      snippet = build(:snippet, source: build(:source, license: "cc_by_sa"))

      expect(snippet.readable_by?(create(:user))).to be(true)
    end

    it "is true for a reader let in" do
      reader = create(:snippet_reader)

      expect(reader.snippet.readable_by?(reader.user)).to be(true)
    end

    it "is false for anyone else when the source is not shareable" do
      expect(build(:snippet).readable_by?(create(:user))).to be(false)
    end
  end

  describe "#paragraphs" do
    def sentences_of(snippet, *bodies)
      bodies.map.with_index do |body, position|
        create(:snippet_sentence, snippet:, body:, position:)
      end
    end

    it "groups the sentences by the body's lines" do
      snippet = create(:snippet, body: "我爱你。\n\n你爱我。他爱她。")
      sentences = sentences_of(snippet, "我爱你。", "你爱我。", "他爱她。")

      expect(snippet.paragraphs).to eq([sentences.take(1), sentences.drop(1)])
    end
  end
end
