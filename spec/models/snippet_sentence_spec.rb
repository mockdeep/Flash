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

  describe ".segmented" do
    it "finds sentences with tokens" do
      create(:snippet_sentence, tokens: [])
      sentence = create(:snippet_sentence, tokens: [{ "text" => "我" }])

      expect(described_class.segmented).to eq([sentence])
    end
  end

  describe "#awaiting_senses?" do
    def awaiting_senses?(*tokens)
      build(:snippet_sentence, tokens:).awaiting_senses?
    end

    it "is true while a word has neither a sense nor an outcome" do
      expect(awaiting_senses?({ "text" => "我" })).to be(true)
    end

    it "is false once every word has an outcome" do
      token = { "text" => "我", "outcome" => "unresolved", "note" => "?" }

      expect(awaiting_senses?(token)).to be(false)
    end

    it "is false once every word has a sense" do
      expect(awaiting_senses?({ "text" => "我", "sense_id" => 1 })).to be(false)
    end

    it "is false for tokens without a Han character" do
      expect(awaiting_senses?({ "text" => "。" })).to be(false)
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
