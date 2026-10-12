# frozen_string_literal: true

require "rails_helper"

RSpec.describe Snippets::Recut do
  def matched(text, sense_id)
    { "text" => text, "outcome" => "matched", "sense_id" => sense_id }
  end

  def words(*texts) = texts.map { |text| { "text" => text } }

  describe ".call" do
    it "keeps the sense of a token left as it was" do
      previous = [matched("我", 7), matched("花了", 8)]

      expect(described_class.call(previous, words("我", "花", "了")).first)
        .to eq(matched("我", 7))
    end

    it "drops the sense of a token cut differently" do
      previous = [matched("我", 7), matched("花了", 8)]

      expect(described_class.call(previous, words("我", "花", "了")).second)
        .to eq("text" => "花")
    end

    it "drops the sense of a token at another place" do
      previous = [matched("我", 7), matched("我我", 8)]

      expect(described_class.call(previous, words("我我", "我")).second)
        .to eq("text" => "我")
    end

    it "drops the sense of a token given another headword" do
      tokens = [{ "text" => "著", "simplified" => "着" }]

      expect(described_class.call([matched("著", 7)], tokens).sole)
        .to eq(tokens.sole)
    end

    it "places a token by the Han characters before it" do
      previous = [{ "text" => "，" }, matched("我", 7)]

      expect(described_class.call(previous, words("我")).sole)
        .to eq(matched("我", 7))
    end

    it "keeps no outcome of a token without a sense" do
      previous = [{ "text" => "我", "outcome" => "unresolved", "note" => "x" }]

      expect(described_class.call(previous, words("我")).sole)
        .to eq("text" => "我")
    end
  end
end
