# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingMap::Links do
  # A public list holding the senses of these headwords, made as needed.
  def list_of(*headwords, name: nil, **attributes)
    attributes = { visibility: "public", **attributes }
    attributes[:name] = name if name
    word_list = create(:word_list, **attributes)
    headwords.each do |headword|
      create(:sense_membership, word_list:, sense: sense(headword, word_list))
    end
    word_list
  end

  def sense(headword, word_list)
    language = word_list.language
    entry = Entry.find_by(headword:, language:) ||
      create(:entry, headword:, language:)
    entry.senses.first || create(:sense, entry:)
  end

  def links = WordListLink.pluck(:word_list_id, :linked_word_list_id, :strength)

  describe ".call" do
    it "joins two public lists that share a word" do
      lists = [list_of("猴子", "石头"), list_of("猴子", "山")]
      described_class.call("zh")

      expect(links).to eq([[*lists.map(&:id), 0.3333]])
    end

    it "leaves private lists out" do
      list_of("猴子")
      list_of("猴子", visibility: "private")
      described_class.call("zh")

      expect(links).to be_empty
    end

    it "leaves level lists out" do
      list_of("猴子")
      list_of("猴子", curriculum: true, level: 3)
      described_class.call("zh")

      expect(links).to be_empty
    end

    it "joins no lists that share nothing" do
      list_of("猴子")
      list_of("山")
      described_class.call("zh")

      expect(links).to be_empty
    end

    it "leaves out the words of the two lowest levels" do
      list_of("的", curriculum: true, level: 1)
      list_of("了", curriculum: true, level: 2)
      [list_of("的", "了", "猴子"), list_of("的", "了", "山")]
      described_class.call("zh")

      expect(links).to be_empty
    end

    it "counts the words of the levels above those" do
      [1, 2, 3].each { list_of("第#{it}", curriculum: true, level: it) }
      [list_of("第3", "猴子"), list_of("第3", "山")]
      described_class.call("zh")

      expect(links.sole.last).to eq(0.3333)
    end

    it "counts a sense, not a headword" do
      flower = list_of("花").senses.sole
      spend = create(:sense, entry: flower.entry)
      create(:sense_membership, word_list: list_of, sense: spend)
      described_class.call("zh")

      expect(links).to be_empty
    end

    it "joins a list only to lists on its band or further out" do
      list_of("猴子", name: "Inner", level: 1)
      list_of("猴子", name: "Outer", level: 2)

      expect(described_class.call("zh"))
        .to include("Inner: Outer 100%", "Outer: no links")
    end

    # Lists further out that each share words with the text and none with
    # each other.
    def lists_apart
      list_of("一", "二", "三", name: "A", level: 2)
      list_of("四", "五", name: "B", level: 2)
      list_of("六", name: "C", level: 2)
      list_of("七", "八", name: "D", level: 2)
    end

    it "keeps a list's three strongest matches" do
      list_of("一", "二", "三", "四", "五", "六", "七", name: "Text", level: 1)
      lists_apart

      expect(described_class.call("zh").first)
        .to eq("Text: A 43%, B 29%, C 14%")
    end

    it "leaves out a match two stronger ones join through a third list" do
      list_of("一", "二", "三", name: "First", level: 1)
      list_of("一", "二", "三", "四", name: "Second", level: 2)
      list_of("一", "二", "三", "四", "五", "六", name: "Third", level: 3)

      expect(described_class.call("zh").first).to eq("First: Second 75%")
    end

    it "keeps a match no stronger pair of lines covers" do
      list_of("一", "二", name: "First", level: 1)
      list_of("一", "三", "四", name: "Second", level: 2)
      list_of("二", "五", "六", "七", name: "Third", level: 3)

      expect(described_class.call("zh").first)
        .to eq("First: Second 25%, Third 20%")
    end

    it "joins lists in a language with no levels" do
      lists = [list_of("猴子"), list_of("猴子")]
      described_class.call("zh")

      expect(links.sole.first(2)).to eq(lists.map(&:id))
    end

    it "says what a run changed" do
      [list_of("猴子"), list_of("猴子")]

      expect(described_class.call("zh").last)
        .to eq("Mandarin: 1 links (1 added, 0 changed, 0 removed)")
    end

    it "keeps the link of a pair that still stands" do
      [list_of("猴子"), list_of("猴子")]
      described_class.call("zh")

      expect { described_class.call("zh") }
        .not_to(change { WordListLink.pluck(:id, :updated_at) })
    end

    it "updates the strength of a pair whose words changed" do
      lists = [list_of("猴子"), list_of("猴子")]
      described_class.call("zh")
      create(:sense_membership, word_list: lists.last)
      described_class.call("zh")

      expect(links.sole.last).to eq(0.5)
    end

    it "removes the link of a pair no longer joined" do
      lists = [list_of("猴子"), list_of("猴子")]
      described_class.call("zh")
      lists.last.update!(visibility: "private")

      expect(described_class.call("zh").last)
        .to eq("Mandarin: 0 links (0 added, 0 changed, 1 removed)")
    end

    it "leaves another language's links alone" do
      [list_of("casa", language: "pt"), list_of("casa", language: "pt")]
      described_class.call("pt")

      expect { described_class.call("zh") }.not_to change(WordListLink, :count)
    end

    it "links every language with a public list when none is named" do
      [list_of("casa", language: "pt"), list_of("casa", language: "pt")]
      [list_of("猴子"), list_of("猴子")]
      described_class.call

      expect(WordListLink.count).to eq(2)
    end
  end
end
