# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Create do
  def create_snippet(source: create(:source), body: "我爱你。你呢？")
    described_class.call(source:, heading: "习俗", body:)
  end

  describe ".call" do
    it "adds the snippet to the source" do
      source = create(:source)

      expect(create_snippet(source:).record.source).to eq(source)
    end

    it "feeds the source's word_list" do
      source = create(:source)

      expect(create_snippet(source:).record.word_list).to eq(source.word_list)
    end

    it "saves the snippet" do
      expect(create_snippet.record).to be_persisted
    end

    it "saves the heading and the body's sentences in order" do
      snippet = create_snippet.record

      expect(snippet.sentences.pluck(:position, :role, :body)).to eq(
        [[0, "heading", "习俗"], [1, "body", "我爱你。"], [2, "body", "你呢？"]],
      )
    end

    it "saves no heading sentence without a heading" do
      snippet = described_class.call(source: create(:source), body: "我。").record

      expect(snippet.sentences.pluck(:role)).to eq(["body"])
    end

    it "gives the sentences the snippet's source" do
      source = create(:source)

      expect(create_snippet(source:).record.sentences.map(&:source).uniq)
        .to eq([source])
    end

    it "returns a success result" do
      expect(create_snippet).to be_success
    end

    context "when the snippet is invalid" do
      it "returns a failure result" do
        expect(create_snippet(body: "")).not_to be_success
      end

      it "saves nothing" do
        source = create(:source)

        expect { create_snippet(source:, body: "") }
          .not_to change(Snippet, :count)
      end
    end
  end
end
