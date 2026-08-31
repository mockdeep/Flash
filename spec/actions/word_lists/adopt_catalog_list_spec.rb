# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::AdoptCatalogList do
  def deck_with(name, cards, user)
    deck = create(:reading_deck, name:, user:)
    cards.each { |attrs| create(:reading_card, deck:, **attrs) }
    deck
  end

  def kept = { front: "明白", back: "understand", reading: "míngbai" }
  def moved = { front: "散", back: "to scatter" }
  def added = { front: "你好", back: "hi", reading: "nǐhǎo" }

  # The real shape: an older generation with no readings, holding one word the
  # catalog still lists here and one it has since moved elsewhere, beside a
  # catalog list that has gained a word the fork never had.
  def legacy_pair
    owner = create(:user)
    deck_with("HSK 1", [kept, added], owner)
    [owner, deck_with("HSK 1", [kept.except(:reading), moved], create(:user))]
  end

  def fronts(deck)
    deck.cards.reload.map(&:front)
  end

  # Language cards keep `front` in their item, so they cannot be looked up by
  # column.
  def card_for(deck, front)
    deck.cards.reload.to_a.find { |card| card.front == front }
  end

  def adopt(owner, fork)
    described_class.call(owner:, ids: [fork.word_list.id], dry_run: false)
  end

  def report_for(owner, fork)
    described_class.call(owner:, ids: [fork.word_list.id])
  end

  describe ".call" do
    it "relinks a surviving word onto the catalog item" do
      owner, fork = legacy_pair

      adopt(owner, fork)

      expect(card_for(fork, "明白").item.word_list)
        .to eq(WordList.find_by(user: owner))
    end

    it "keeps the relinked card's progress" do
      owner, fork = legacy_pair
      card_for(fork, "明白").update!(correct_count: 5, view_count: 9)

      adopt(owner, fork)

      expect(card_for(fork, "明白"))
        .to have_attributes(correct_count: 5, view_count: 9)
    end

    it "drops a card whose word the catalog list no longer holds" do
      owner, fork = legacy_pair

      adopt(owner, fork)

      expect(fronts(fork)).not_to include("散")
    end

    it "adds the catalog words the fork never had" do
      owner, fork = legacy_pair

      adopt(owner, fork)

      expect(fronts(fork)).to contain_exactly("明白", "你好")
    end

    it "repoints the deck at the catalog list" do
      owner, fork = legacy_pair

      adopt(owner, fork)

      expect(fork.reload.word_list).to eq(WordList.find_by(user: owner))
    end

    it "destroys the emptied fork word_list" do
      owner, fork = legacy_pair
      list = fork.word_list

      adopt(owner, fork)

      expect(WordList.exists?(list.id)).to be(false)
    end

    it "reports what it relinked, dropped and added" do
      owner, fork = legacy_pair

      report = report_for(owner, fork)

      expect(report.adopted.sole)
        .to have_attributes(relinked: 1, dropped: 1, added: 1)
    end

    it "writes nothing on a dry run" do
      owner, fork = legacy_pair

      report_for(owner, fork)

      expect(fronts(fork)).to contain_exactly("明白", "散")
    end

    it "skips a list the owner holds no list of that name for" do
      owner, = legacy_pair
      stray = deck_with("Not In Catalog", [kept], create(:user))

      report = report_for(owner, stray)

      expect(report.skipped.sole.reason).to eq(:no_catalog_match)
    end

    it "refuses to adopt one of the owner's own lists" do
      owner, = legacy_pair
      own = Deck.find_by(user: owner)

      report = report_for(owner, own)

      expect(report.skipped.sole.reason).to eq(:owner_list)
    end
  end
end
