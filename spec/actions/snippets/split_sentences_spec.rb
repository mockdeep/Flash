# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::SplitSentences do
  describe ".call" do
    it "splits on terminal punctuation" do
      expect(described_class.call("我爱你。你呢？好！")).to eq(["我爱你。", "你呢？", "好！"])
    end

    it "keeps a closing quote with the sentence it ends" do
      expect(described_class.call("他说：“好。”我走了。")).to eq(["他说：“好。”", "我走了。"])
    end

    it "splits on line breaks" do
      expect(described_class.call("孔乙己\n鲁迅")).to eq(["孔乙己", "鲁迅"])
    end

    it "drops blank lines and surrounding space" do
      expect(described_class.call("  我爱你。 \n\n  \n")).to eq(["我爱你。"])
    end
  end
end
