# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippet do
  it { is_expected.to belong_to(:word_list) }
  it { is_expected.to have_many(:sentences).dependent(:delete_all) }

  it { is_expected.to validate_presence_of(:word_list) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:body) }
  it { is_expected.to validate_length_of(:body).is_at_most(20_000) }

  it "rejects a list in another language" do
    snippet = build(:snippet, word_list: build(:word_list, language: "ja"))

    expect(snippet).not_to be_valid
  end

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
end
