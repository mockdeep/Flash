# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingMap::Layout do
  def lists(count, **) = create_list(:word_list, count, **)

  def link(word_list, linked_word_list, strength)
    create(:word_list_link, word_list:, linked_word_list:, strength:)
  end

  # A backbone of three lists, then lists on their own, with the links
  # from the backbone's first list to each of those.
  def backbone_and(*strengths)
    spoke = lists(3)
    alone = lists(strengths.size)
    chain = spoke.each_cons(2).map { |pair| link(*pair, 0.5) }
    links =
      strengths.zip(alone).filter_map do |strength, list|
        link(spoke.first, list, strength) if strength
      end

    [spoke, alone, chain + links]
  end

  def angles_of(placed, lists, links)
    described_class.call(lists, links).values_at(*placed)
  end

  describe ".call" do
    it "places nothing with no lists" do
      expect(described_class.call([], [])).to be_empty
    end

    it "puts a lone list up the center" do
      list = create(:word_list)

      expect(described_class.call([list], [])).to eq(list => 90.0)
    end

    it "gives strongly linked lists one angle" do
      spoke, _, links = backbone_and

      expect(angles_of(spoke, spoke, links)).to eq([90.0, 90.0, 90.0])
    end

    it "puts the group with the most lists up the center" do
      spoke, alone, links = backbone_and(nil)

      expect(angles_of(spoke, alone + spoke, links)).to eq([90.0, 90.0, 90.0])
    end

    it "puts the first of two groups of a size up the center" do
      pair = lists(2)

      expect(described_class.call(pair, [])[pair.first]).to eq(90.0)
    end

    it "keeps weakly linked lists apart" do
      pair = lists(2)
      links = [link(*pair, 0.19)]

      expect(described_class.call(pair, links)[pair.last]).not_to eq(90.0)
    end

    it "puts the group closest to the center group nearest it" do
      spoke, alone, links = backbone_and(0.1)

      expect(angles_of(alone, spoke + alone, links)).to eq([70.0])
    end

    it "puts a group with no link to the center group furthest out" do
      spoke, alone, links = backbone_and(nil)

      expect(angles_of(alone, spoke + alone, links)).to eq([10.0])
    end

    it "puts a less close group further out, on the emptier side" do
      spoke, alone, links = backbone_and(0.1, 0.05)

      expect(angles_of(alone, spoke + alone, links)).to eq([70.0, 140.0])
    end

    it "puts a group on the side of the group it is linked to" do
      spoke, alone, links = backbone_and(0.1, nil)
      links << link(*alone, 0.1)

      expect(angles_of(alone, spoke + alone, links)).to eq([70.0, 10.0])
    end

    it "keeps a group on the side it is stored on" do
      spoke, alone, links = backbone_and(0.1)
      alone.first.update!(angle: 150)

      expect(angles_of(alone, spoke + alone, links)).to eq([110.0])
    end

    it "places a group stored in the center afresh" do
      spoke, alone, links = backbone_and(0.1)
      alone.first.update!(angle: 90)

      expect(angles_of(alone, spoke + alone, links)).to eq([70.0])
    end
  end
end
