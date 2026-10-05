# frozen_string_literal: true

require "rails_helper"

RSpec.describe Compendium::Lookup do
  def flower(gloss: "flower")
    create(:sense, entry: create(:entry, headword: "花", reading: "huā"), gloss:)
  end

  describe ".call" do
    it "shows each entry for a headword with its senses" do
      sense = flower
      entry = sense.entry

      expect(described_class.call("花")).to start_with(
        "花 huā (entry ##{entry.id})\n  ##{sense.id} flower; lists: none",
      )
    end

    it "finds senses by their gloss" do
      sense = flower

      expect(described_class.call("flow")).to include("##{sense.id} flower")
    end

    it "names the lists that hold a sense, with its category there" do
      sense = flower
      list = create(:word_list, name: "HSK 2")
      create(:sense_membership, sense:, word_list: list, category: "noun")

      expect(described_class.call("花")).to include("lists: HSK 2 (noun)")
    end

    it "marks a membership not yet categorized" do
      create(:sense_membership, sense: flower, category: nil)

      expect(described_class.call("花")).to include("(uncategorized)")
    end

    it "counts the snippet sentences that point at a sense" do
      tokens = [{ "text" => "花", "sense_id" => flower.id }]
      create(:snippet_sentence, tokens:)

      expect(described_class.call("花")).to end_with("snippet sentences: 1")
    end

    it "says when nothing matches" do
      expect(described_class.call("花")).to eq("Nothing matches 花")
    end
  end
end
