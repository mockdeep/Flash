# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReadingMap::Angles do
  # A list holding the senses of these headwords, made as needed.
  def list_of(*headwords, **)
    word_list = create(:word_list, **)
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

  def public_list(*, **) = list_of(*, visibility: "public", **)

  def angle_of(list, language = "zh")
    described_class.call(language)
    list.reload.angle
  end

  describe ".call" do
    it "lays the public lists out" do
      expect(angle_of(public_list("猴子"))).to eq(90.0)
    end

    it "puts a private list beside the public list it shares words with" do
      public_list("猴子")
      public_list("山")

      expect(angle_of(list_of("山"))).to eq(10.0)
    end

    it "puts a private list between the public lists it shares words with" do
      public_list("猴子")
      public_list("山")

      expect(angle_of(list_of("猴子", "山"))).to eq(50.0)
    end

    it "counts a closer public list for more" do
      public_list("猴子", "石头")
      public_list("山")

      expect(angle_of(list_of("猴子", "山"))).to eq(42.0)
    end

    it "puts a private list that shares nothing in the centre" do
      public_list("猴子")
      public_list("山")

      expect(angle_of(list_of("水"))).to eq(90.0)
    end

    it "spreads private lists out with no public list to go by" do
      lists = [list_of("猴子"), list_of("山"), list_of("水")]
      described_class.call("zh")

      expect(lists.map { it.reload.angle }).to eq([10.0, 90.0, 170.0])
    end

    it "puts a lone private list in the centre" do
      expect(angle_of(list_of("猴子"))).to eq(90.0)
    end

    it "gives a list with no words no angle" do
      expect(angle_of(create(:word_list))).to be_nil
    end

    it "gives a level list no angle" do
      expect(angle_of(list_of("猴子", curriculum: true))).to be_nil
    end

    it "lists each list by its angle, then how many moved" do
      public_list("猴子", name: "Story")
      list_of("山", name: "Notes")
      lines = [" 90.0  Story", " 90.0  Notes"]
      lines << "Mandarin: 2 lists placed (2 moved)"

      expect(described_class.call("zh")).to eq(lines)
    end

    it "moves nothing on a second run" do
      public_list("猴子")
      described_class.call("zh")

      expect(described_class.call("zh").last)
        .to eq("Mandarin: 1 lists placed (0 moved)")
    end

    it "places every language's lists when none is named" do
      lists = [list_of("猴子"), list_of("casa", language: "pt")]
      described_class.call

      expect(lists.map { it.reload.angle }).to eq([90.0, 90.0])
    end
  end
end
