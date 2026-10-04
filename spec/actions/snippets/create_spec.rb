# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Create do
  def create_snippet(list_name: "Kong Yiji", title: "孔乙己", body: "我爱你。你呢？")
    described_class.call(user: default_user, list_name:, title:, body:)
  end

  describe ".call" do
    it "creates a Mandarin word_list of the given name" do
      create_snippet

      expect(default_user.word_lists.last)
        .to have_attributes(name: "Kong Yiji", language: "zh")
    end

    it "reuses the user's word_list of that name" do
      word_list = create(:word_list, name: "Kong Yiji")

      expect(create_snippet.record.word_list).to eq(word_list)
    end

    it "saves the snippet" do
      expect(create_snippet.record).to be_persisted
    end

    it "saves the body's sentences in order" do
      snippet = create_snippet.record

      expect(snippet.sentences.pluck(:position, :body))
        .to eq([[0, "我爱你。"], [1, "你呢？"]])
    end

    it "returns a success result" do
      expect(create_snippet).to be_success
    end

    context "when the snippet is invalid" do
      it "returns a failure result" do
        expect(create_snippet(title: "")).not_to be_success
      end

      it "does not create the word_list" do
        expect { create_snippet(title: "") }.not_to change(WordList, :count)
      end
    end

    context "when the list name is blank" do
      it "reports the list's error on the snippet" do
        snippet = create_snippet(list_name: "").record

        expect(snippet.errors.full_messages)
          .to include("List name can't be blank")
      end
    end

    context "when the list is in another language" do
      it "returns a failure result" do
        create(:word_list, name: "Kong Yiji", language: "ja")

        expect(create_snippet).not_to be_success
      end

      it "reports the language on the snippet" do
        create(:word_list, name: "Kong Yiji", language: "ja")

        expect(create_snippet.record.errors.full_messages)
          .to include("List language must be Mandarin")
      end
    end

    context "when a field is missing" do
      it "returns a failure result rather than raising" do
        result = described_class.call(user: default_user, title: "孔乙己")

        expect(result).not_to be_success
      end
    end
  end
end
