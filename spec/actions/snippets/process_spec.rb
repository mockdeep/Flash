# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Process do
  def segment_each_sentence_by_character
    llm.respond do |call|
      sentences =
        JSON.parse(call.prompt).map do |row|
          { id: row["id"], words: row["sentence"].chars }
        end
      { sentences: }
    end
  end

  describe ".call" do
    it "segments every sentence not yet segmented" do
      segment_each_sentence_by_character
      sentence = create(:snippet_sentence, body: "我爱你")

      described_class.call

      expect(sentence.reload.status).to eq(:in_progress)
    end

    it "leaves segmented sentences alone" do
      tokens = [{ "text" => "我", "sense_id" => 1 }]
      create(:snippet_sentence, tokens:)

      described_class.call

      expect(llm.calls).to be_empty
    end

    it "works in batches" do
      segment_each_sentence_by_character
      stub_const("Snippets::Process::SEGMENT_BATCH", 1)
      create_list(:snippet_sentence, 2, body: "我")

      described_class.call

      expect(llm.calls.size).to eq(2)
    end

    it "yields each batch it finishes" do
      segment_each_sentence_by_character
      sentence = create(:snippet_sentence, body: "我")

      expect { |block| described_class.call(&block) }
        .to yield_with_args([sentence])
    end
  end
end
