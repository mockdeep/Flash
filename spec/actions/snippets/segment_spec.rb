# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Segment do
  def answer(*words)
    { sentences: [{ id: 0, words: }] }
  end

  def segmented_words(body)
    sentence = create(:snippet_sentence, body:)
    described_class.call([sentence])
    sentence.reload.tokens.pluck("text")
  end

  describe ".call" do
    it "stores the words as tokens" do
      llm.answer(answer("我", "爱", "你"))

      expect(segmented_words("我爱你。")).to eq(["我", "爱", "你"])
    end

    it "asks Sonnet" do
      llm.answer(answer("我"))

      segmented_words("我")

      expect(llm.calls.sole.model).to eq("claude-sonnet-5-5")
    end

    it "asks about every sentence in one request" do
      llm.answer({ sentences: [] }, answer("我"), answer("你"))
      sentences = ["我", "你"].map { |body| create(:snippet_sentence, body:) }
      described_class.call(sentences)

      expect(llm.calls.first.prompt)
        .to eq('[{"id":0,"sentence":"我"},{"id":1,"sentence":"你"}]')
    end

    it "asks again about a sentence whose words drop a character" do
      llm.answer(answer("我", "你"), answer("我", "爱你"))

      expect(segmented_words("我爱你。")).to eq(["我", "爱你"])
    end

    it "asks again about a sentence missing from the answer" do
      llm.answer({ sentences: [] }, answer("我", "爱你"))

      expect(segmented_words("我爱你。")).to eq(["我", "爱你"])
    end

    it "asks again about a sentence answered with no words" do
      llm.answer(answer, answer("2008", "。"))

      expect(segmented_words("2008。")).to eq(["2008", "。"])
    end

    it "falls back to one token per character after two failures" do
      llm.answer(answer("我", "你"), answer("我", "你"))

      expect(segmented_words("我爱你")).to eq(["我", "爱", "你"])
    end
  end
end
