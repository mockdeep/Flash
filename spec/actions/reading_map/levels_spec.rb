# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingMap::Levels do
  def list_of(*headwords, language: "zh", category: nil, **attributes)
    word_list = create(:word_list, language:, **attributes)
    headwords.each do |headword|
      entry = Entry.find_by(language:, headword:) ||
        create(:entry, language:, headword:)
      sense = create(:sense, entry:)
      create(:sense_membership, sense:, word_list:, category:)
    end
    word_list
  end

  def level_list(level, *headwords, **)
    list_of(*headwords, curriculum: true, level:, **)
  end

  describe ".call" do
    it "places a list on the lowest level that holds enough of its words" do
      level_list(1, "一", "二", "三", "四")
      list = list_of("一", "二", "三", "四", "五")
      described_class.call("zh")

      expect(list.reload.level).to eq(1)
    end

    it "counts the words of the levels below" do
      level_list(1, "一", "二")
      level_list(2, "三", "四")
      list = list_of("一", "二", "三", "四")
      described_class.call("zh")

      expect(list.reload.level).to eq(2)
    end

    it "passes over a level that holds too few of its words" do
      level_list(1, "一", "二", "三")
      level_list(2, "四")
      list = list_of("一", "二", "三", "四", "五")
      described_class.call("zh")

      expect(list.reload.level).to eq(2)
    end

    it "places a list no level holds enough of one past the top level" do
      level_list(1, "一")
      list = list_of("一", "二")
      described_class.call("zh")

      expect(list.reload.level).to eq(2)
    end

    it "leaves out words filed as names" do
      level_list(1, "一")
      list = list_of("一")
      create(:sense_membership, word_list: list, category: "proper noun")
      described_class.call("zh")

      expect(list.reload.level).to eq(1)
    end

    it "counts a character a level holds inside a longer word" do
      level_list(1, "没有")
      list = list_of("没")
      described_class.call("zh")

      expect(list.reload.level).to eq(1)
    end

    it "counts no letter of a word in a language written with spaces" do
      level_list(1, "casa", language: "pt")
      list = list_of("a", language: "pt")
      described_class.call("pt")

      expect(list.reload.level).to eq(2)
    end

    it "matches headwords whatever their case" do
      level_list(1, "casa", language: "pt")
      list = list_of("Casa", language: "pt")
      described_class.call("pt")

      expect(list.reload.level).to eq(1)
    end

    it "keeps a level already set" do
      level_list(1, "一")
      list = list_of("一", level: 5)
      described_class.call("zh")

      expect(list.reload.level).to eq(5)
    end

    it "leaves a list with no words without a level" do
      level_list(1, "一")
      list = create(:word_list)
      described_class.call("zh")

      expect(list.reload.level).to be_nil
    end

    it "reports each list it places, with the share each level holds" do
      level_list(1, "一")
      level_list(2, "二")
      list_of("一", "二", "三", name: "Story")

      expect(described_class.call("zh")).to eq(["Story: level 3 (33% 66%)"])
    end

    it "places every language with level lists when none is named" do
      level_list(1, "一")
      level_list(1, "casa", language: "pt")
      lists = [list_of("一"), list_of("casa", language: "pt")]
      described_class.call

      expect(lists.map { it.reload.level }).to eq([1, 1])
    end

    it "places nothing in a language with no level lists" do
      list_of("一", curriculum: true)
      list = list_of("一")
      described_class.call("ja")

      expect(list.reload.level).to be_nil
    end

    it "says a language has no level lists" do
      expect(described_class.call("ja")).to eq(["Japanese: no level lists"])
    end

    it "places nothing while a level list has no level" do
      level_list(1, "一")
      list_of("二", curriculum: true, name: "HSK 2")

      expect(described_class.call("zh")).to eq(["Mandarin: HSK 2 has no level"])
    end
  end
end
