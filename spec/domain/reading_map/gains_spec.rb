# frozen_string_literal: true

RSpec.describe ReadingMap::Gains do
  # A list holding the senses of these headwords, made as needed.
  def list_of(*headwords)
    word_list = create(:word_list)
    headwords.each do |headword|
      entry = Entry.find_by(headword:) || create(:entry, headword:)
      sense = entry.senses.first || create(:sense, entry:)
      create(:sense_membership, word_list:, sense:)
    end
    word_list
  end

  def gains(from, to, user: default_user)
    described_class.for(user, [[from.id, to.id]])[[from.id, to.id]]
  end

  def learn(headword, correct_streak: 3)
    sense = Entry.find_by!(headword:).senses.sole
    create(:skill_score, sense:, correct_streak:)
  end

  describe ".for" do
    it "counts the other list's words the first teaches" do
      from = list_of("猴子", "石头")
      to = list_of("猴子", "石头", "山")

      expect(gains(from, to).words).to eq(2)
    end

    it "counts the other list's words in all" do
      from = list_of("猴子")
      to = list_of("猴子", "山")

      expect(gains(from, to).total).to eq(2)
    end

    it "leaves out a word the learner knows in full" do
      lists = [list_of("猴子", "石头"), list_of("猴子", "石头")]
      learn("猴子")

      expect(gains(*lists).words).to eq(1)
    end

    it "counts a word the learner knows in part" do
      lists = [list_of("猴子"), list_of("猴子")]
      learn("猴子", correct_streak: 2)

      expect(gains(*lists).words).to eq(1)
    end

    it "leaves out a word the first list holds only one sense of" do
      from = list_of("花")
      to = list_of("花")
      spend = create(:sense, entry: Entry.find_by!(headword: "花"))
      create(:sense_membership, word_list: to, sense: spend)

      expect(gains(from, to).words).to eq(0)
    end

    it "goes by the learner asked about" do
      lists = [list_of("猴子"), list_of("猴子")]
      learn("猴子")

      expect(gains(*lists, user: create(:user)).words).to eq(1)
    end

    it "works out many pairs at once" do
      lists = [list_of("猴子"), list_of("猴子", "山")]
      pairs = [lists.map(&:id), lists.reverse.map(&:id)]

      expect(described_class.for(default_user, pairs).values.map(&:total))
        .to contain_exactly(1, 2)
    end

    it "leaves out a pair whose second list has no words" do
      pair = [list_of("猴子"), create(:word_list)].map(&:id)

      expect(described_class.for(default_user, [pair])).to be_empty
    end

    it "asks nothing with no pairs" do
      expect(described_class.for(default_user, [])).to be_empty
    end
  end

  describe "#percent" do
    it "gives the share gained as a whole number, rounded down" do
      expect(described_class.new(total: 3, words: 2).percent).to eq(66)
    end
  end
end
