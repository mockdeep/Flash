# frozen_string_literal: true

require "rails_helper"

RSpec.describe SnippetSentence do
  it { is_expected.to belong_to(:snippet) }

  it { is_expected.to validate_presence_of(:snippet) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_presence_of(:position) }

  it "keeps positions unique within a snippet" do
    sentence = create(:snippet_sentence)
    snippet, position = sentence.values_at(:snippet, :position)

    expect { create(:snippet_sentence, snippet:, position:) }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe ".unsegmented" do
    it "finds sentences without tokens" do
      sentence = create(:snippet_sentence, tokens: [])
      create(:snippet_sentence, tokens: [{ "text" => "我" }])

      expect(described_class.unsegmented).to eq([sentence])
    end
  end

  describe "#han" do
    it "returns the sentence's Han characters without punctuation" do
      sentence = build(:snippet_sentence, body: "“你好，”他说。")

      expect(sentence.han).to eq("你好他说")
    end
  end

  describe "#partitioned_by?" do
    def partitioned_by?(words)
      build(:snippet_sentence, body: "我爱你。").partitioned_by?(words)
    end

    it "is true when the words rejoin to the sentence" do
      expect(partitioned_by?(["我", "爱", "你", "。"])).to be(true)
    end

    it "ignores punctuation the words leave out" do
      expect(partitioned_by?(["我", "爱你"])).to be(true)
    end

    it "is false when a character is dropped" do
      expect(partitioned_by?(["我", "你"])).to be(false)
    end

    it "is false when a character is substituted" do
      expect(partitioned_by?(["我", "愛", "你"])).to be(false)
    end
  end

  describe "#status" do
    def status(*tokens) = build(:snippet_sentence, tokens:).status

    it "is new before segmenting" do
      expect(status).to eq(:new)
    end

    it "is finished when every word has a sense" do
      tokens = [{ "text" => "我", "sense_id" => 1 }, { "text" => "。" }]

      expect(status(*tokens)).to eq(:finished)
    end

    it "is in progress while a word has no sense" do
      expect(status({ "text" => "我" })).to eq(:in_progress)
    end

    it "is in progress while a token carries working keys" do
      token = { "text" => "我", "sense_id" => 1, "outcome" => "matched" }

      expect(status(token)).to eq(:in_progress)
    end
  end
end
