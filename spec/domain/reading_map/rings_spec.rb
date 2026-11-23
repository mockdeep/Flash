# frozen_string_literal: true

RSpec.describe ReadingMap::Rings do
  def level_list(level, **)
    create(:word_list, curriculum: true, level:, **)
  end

  def rings(language = "zh") = described_class.new(language)

  describe "#count" do
    it "is a ring per level and one past the top" do
      [1, 2].each { level_list(it) }

      expect(rings.count).to eq(3)
    end

    it "is one in a language with no level lists" do
      expect(rings.count).to eq(1)
    end

    it "counts two lists of one level once" do
      2.times { level_list(1) }

      expect(rings.count).to eq(2)
    end

    it "leaves out another language's levels" do
      level_list(1, language: "pt")

      expect(rings.count).to eq(1)
    end
  end

  describe "#level_lists" do
    it "gives the level lists, lowest level first" do
      lists = [2, 1].map { level_list(it) }

      expect(rings.level_lists).to eq(lists.reverse)
    end

    it "leaves out a level list with no level" do
      level_list(nil)

      expect(rings.level_lists).to be_empty
    end
  end

  describe "#of" do
    it "is the ring of the list's level" do
      [3, 5].each { level_list(it) }

      expect(rings.of(build(:word_list, level: 5))).to eq(2)
    end

    it "is the last ring for a list past the top level" do
      level_list(1)

      expect(rings.of(build(:word_list, level: 2))).to eq(2)
    end

    it "is the last ring for a list with no level" do
      level_list(1)

      expect(rings.of(build(:word_list))).to eq(2)
    end

    it "is the one ring of a language with no level lists" do
      expect(rings.of(build(:word_list, level: 4))).to eq(1)
    end
  end
end
