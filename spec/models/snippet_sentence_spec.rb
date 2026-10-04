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

  describe "#finished?" do
    def sentence(*tokens) = build(:snippet_sentence, tokens:)

    it "is true when every word has a sense" do
      tokens = [{ "text" => "我", "sense_id" => 1 }, { "text" => "。" }]

      expect(sentence(*tokens)).to be_finished
    end

    it "is false before segmenting" do
      expect(sentence).not_to be_finished
    end

    it "is false when a word has no sense" do
      expect(sentence({ "text" => "我" })).not_to be_finished
    end

    it "is false while a token carries working keys" do
      token = { "text" => "我", "sense_id" => 1, "outcome" => "matched" }

      expect(sentence(token)).not_to be_finished
    end
  end
end
