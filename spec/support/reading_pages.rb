# frozen_string_literal: true

module Helpers
  module ReadingPageHelpers
    # The default user's deck over a snippet of two one-word sentences, with
    # pages a character long, so each sentence is a page; and the second
    # sentence.
    def two_page_deck
      stub_const("ReadingPages::CHARACTERS", 1)
      snippet = create(:snippet, body: "我。你。")
      sentences =
        ["我", "你"].map.with_index do |word, position|
          one_word_sentence(snippet, word, position)
        end
      word_list = snippet.word_list
      [create(:reading_deck, word_list:), sentences.last]
    end

    def one_word_sentence(snippet, word, position)
      sense = create(:sense, entry: create(:entry, headword: word))
      tokens = [{ "text" => word, "sense_id" => sense.id }, { "text" => "。" }]
      body = "#{word}。"
      create(:snippet_sentence, snippet:, position:, body:, tokens:)
    end
  end
end

RSpec.configure { |config| config.include(Helpers::ReadingPageHelpers) }
