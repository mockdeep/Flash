# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Segment do
  # Each word is a text, or a [text, simplified] pair for a traditional one,
  # or a [text, simplified, traditional] triple for a simplified one.
  def answer(*words)
    words =
      words.map do |text, simplified = text, traditional = text|
        { text:, simplified:, traditional: }
      end

    { sentences: [{ id: 0, words: }] }
  end

  def segmented_tokens(body)
    sentence = create(:snippet_sentence, body:)
    described_class.call([sentence])
    sentence.reload.tokens
  end

  def segmented_words(body) = segmented_tokens(body).pluck("text")

  # Each word is a text, or a [text, headword] pair for a capitalised one.
  def headword_answer(*words)
    words = words.map { |text, headword = text| { text:, headword: } }

    { sentences: [{ id: 0, words: }] }
  end

  def skipped_answer(text)
    words = [{ text:, headword: text, skip: "foreign" }]

    { sentences: [{ id: 0, words: }] }
  end

  def portuguese_tokens(body)
    word_list = create(:word_list, language: "pt")
    snippet = create(:snippet, word_list:)
    sentence = create(:snippet_sentence, snippet:, body:)
    described_class.call([sentence])
    sentence.reload.tokens
  end

  def filipino_tokens(body)
    word_list = create(:word_list, language: "fil")
    snippet = create(:snippet, word_list:)
    sentence = create(:snippet_sentence, snippet:, body:)
    described_class.call([sentence])
    sentence.reload.tokens
  end

  def recut(tokens, *words)
    llm.answer(answer(*words))
    body = tokens.pluck(:text).join
    sentence = create(:snippet_sentence, body:, tokens:)
    described_class.call([sentence], feedback: { sentence => "split 花了" })
    sentence.reload.tokens
  end

  describe ".call in Portuguese" do
    it "keeps the lower-cased form of a capitalised word" do
      llm.answer(headword_answer(["Ela", "ela"], "saiu", "."))

      expect(portuguese_tokens("Ela saiu.").first)
        .to eq("text" => "Ela", "headword" => "ela")
    end

    it "keeps a fixed phrase as one token" do
      llm.answer(headword_answer(["De repente", "de repente"], "parou", "."))

      expect(portuguese_tokens("De repente parou.").pluck("text"))
        .to eq(["De repente", "parou", "."])
    end

    it "asks again when a headword is more than the word in lower case" do
      llm.answer(headword_answer(["falava", "falar"]))
      llm.answer(headword_answer("falava"))

      expect(portuguese_tokens("falava")).to eq([{ "text" => "falava" }])
    end

    it "studies an abbreviation under the word it stands for" do
      llm.answer(headword_answer(["D.", "Dona"], "Inácia"))

      expect(portuguese_tokens("D. Inácia").first)
        .to eq("text" => "D.", "headword" => "Dona")
    end

    it "asks again when a headword is not the abbreviation written out" do
      llm.answer(headword_answer(["Sr.", "Doutor"]))
      llm.answer(headword_answer(["Sr.", "Senhor"]))

      expect(portuguese_tokens("Sr.").sole["headword"]).to eq("Senhor")
    end

    it "writes out only a word that ends in a full stop" do
      llm.answer(headword_answer(["Sr", "Senhor"]))
      llm.answer(headword_answer("Sr"))

      expect(portuguese_tokens("Sr")).to eq([{ "text" => "Sr" }])
    end

    it "keeps why a word was skipped" do
      title = "Gone with the Wind"
      llm.answer(skipped_answer(title))

      expect(portuguese_tokens(title).sole)
        .to eq("text" => title, "skip" => "foreign")
    end

    it "offers the reasons to skip a word" do
      llm.answer(headword_answer("sim"))
      portuguese_tokens("sim")

      expect(llm.calls.sole.schema.to_json)
        .to include('"skip":{"type":"string","enum":["foreign","name"]}')
    end

    it "asks for each word's headword" do
      llm.answer(headword_answer("sim"))
      portuguese_tokens("sim")

      expect(llm.calls.sole.schema.to_json)
        .to include('"required":["text","headword"]')
    end

    it "falls back to words and punctuation after two failures" do
      2.times { llm.answer({ sentences: [] }) }

      expect(portuguese_tokens("Diga-me, Ana.").pluck("text"))
        .to eq(["Diga-me", ",", "Ana", "."])
    end
  end

  describe ".call in Filipino" do
    it "keeps a word's accents" do
      llm.answer(headword_answer(["Ibinukás", "ibinukás"], "niya", "."))

      expect(filipino_tokens("Ibinukás niya.").first)
        .to eq("text" => "Ibinukás", "headword" => "ibinukás")
    end

    it "asks again when a headword drops an accent" do
      llm.answer(headword_answer(["susô", "suso"]))
      llm.answer(headword_answer("susô"))

      expect(filipino_tokens("susô")).to eq([{ "text" => "susô" }])
    end

    it "studies a Filipino abbreviation under the word it stands for" do
      llm.answer(headword_answer(["Gng.", "Ginang"], "Reyes"))

      expect(filipino_tokens("Gng. Reyes").first)
        .to eq("text" => "Gng.", "headword" => "Ginang")
    end

    it "falls back to words and punctuation after two failures" do
      2.times { llm.answer({ sentences: [] }) }

      expect(filipino_tokens("Kaya't umalis siya.").pluck("text"))
        .to eq(["Kaya't", "umalis", "siya", "."])
    end
  end

  describe ".call" do
    it "stores the words as tokens" do
      llm.answer(answer("我", "爱", "你"))

      expect(segmented_words("我爱你。")).to eq(["我", "爱", "你"])
    end

    it "keeps the simplified form of a traditional word" do
      llm.answer(answer(["圖書館", "图书馆"]))

      expect(segmented_tokens("圖書館").sole)
        .to eq("text" => "圖書館", "headword" => "图书馆")
    end

    it "keeps no simplified form for a word already simplified" do
      llm.answer(answer("我"))

      expect(segmented_tokens("我").sole).to eq("text" => "我")
    end

    it "keeps the traditional form of a simplified word" do
      llm.answer(answer(["发", "发", "髮"]))

      expect(segmented_tokens("发").sole)
        .to eq("text" => "发", "traditional" => "髮")
    end

    it "asks again when a traditional form is not as long as its word" do
      llm.answer(answer(["头发", "头发", "頭"]), answer(["头发", "头发", "頭髮"]))

      expect(segmented_tokens("头发").sole["traditional"]).to eq("頭髮")
    end

    it "asks for no traditional form in Portuguese" do
      llm.answer(headword_answer("saiu"))
      portuguese_tokens("saiu")

      expect(llm.calls.sole.schema.to_json).not_to include("traditional")
    end

    it "asks again when a simplified form is not as long as its word" do
      llm.answer(answer(["圖書館", "图书"]), answer(["圖書館", "图书馆"]))

      expect(segmented_tokens("圖書館").sole["headword"]).to eq("图书馆")
    end

    it "offers no reason to skip a word in Mandarin" do
      llm.answer(answer("我"))
      segmented_tokens("我")

      expect(llm.calls.sole.schema.to_json).not_to include("skip")
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

    it "passes on what was wrong with an earlier segmentation" do
      recut([{ text: "花了" }], "花", "了")

      expect(llm.calls.sole.prompt)
        .to include('"feedback":"split 花了","previous":["花了"]')
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

  describe ".call with feedback" do
    it "keeps the sense of a token the new cut leaves alone" do
      tokens = [{ text: "我", sense_id: 7 }, { text: "花了", sense_id: 8 }]

      expect(recut(tokens, "我", "花", "了").first)
        .to eq("text" => "我", "sense_id" => 7)
    end
  end

  describe ".call without feedback" do
    it "sends no previous segmentation" do
      llm.answer(answer("我"))
      sentence = create(:snippet_sentence, body: "我", tokens: [{ text: "我" }])
      described_class.call([sentence])

      expect(llm.calls.sole.prompt).to eq('[{"id":0,"sentence":"我"}]')
    end

    it "keeps no sense from the earlier tokens" do
      llm.answer(answer("我"))
      tokens = [{ text: "我", outcome: "matched", sense_id: 7 }]
      sentence = create(:snippet_sentence, body: "我", tokens:)
      described_class.call([sentence])

      expect(sentence.reload.tokens.sole).to eq("text" => "我")
    end
  end
end
