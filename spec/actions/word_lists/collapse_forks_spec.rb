# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::CollapseForks do
  def word
    { front: "明白", back: "understand" }
  end

  def deck_with(name, cards, user)
    deck = create(:reading_deck, name:, user:)
    cards.each { |attrs| create(:reading_card, deck:, **attrs) }
    deck
  end

  # A catalog list and one other account's copy of it, under the same name.
  # Returns the catalog's owner and the copier's deck.
  def pair(catalog_cards, fork_cards, name: "HSK 1")
    owner = create(:user)
    deck_with("HSK 1", catalog_cards, owner)
    [owner, deck_with(name, fork_cards, create(:user))]
  end

  # The byte-identical case, which is the whole of what this PR collapses.
  def matched_pair
    pair([word], [word])
  end

  def catalog_list(owner)
    WordList.where(user: owner).sole
  end

  def collapse(owner)
    described_class.call(owner:, dry_run: false)
  end

  def studied(deck)
    deck.cards.sole.tap do |card|
      card.update!(correct_count: 4, correct_streak: 2, view_count: 9)
    end
  end

  # Builds a catalog list and a fork beside it, then reports on the fork.
  # Every gate example differs only in the content of the two.
  def skipped_row(catalog_cards, fork_cards, name: "HSK 1")
    owner, = pair(catalog_cards, fork_cards, name:)
    described_class.call(owner:).skipped.sole
  end

  describe ".call" do
    it "relinks the fork's cards onto the catalog items" do
      owner, fork = matched_pair
      card = fork.cards.sole

      collapse(owner)

      expect(card.reload.item.word_list).to eq(catalog_list(owner))
    end

    it "keeps the relinked card's progress counters" do
      owner, fork = matched_pair
      card = studied(fork)

      collapse(owner)

      expect(card.reload)
        .to have_attributes(correct_count: 4, correct_streak: 2, view_count: 9)
    end

    it "repoints the fork's deck at the catalog list" do
      owner, fork = matched_pair

      collapse(owner)

      expect(fork.reload.word_list).to eq(catalog_list(owner))
    end

    it "destroys the emptied fork word_list" do
      owner, fork = matched_pair
      list = fork.word_list

      collapse(owner)

      expect(WordList.exists?(list.id)).to be(false)
    end

    it "reports the collapsed list" do
      owner, fork = matched_pair
      list = fork.word_list

      report = collapse(owner)

      expect(report.collapsed.sole).to have_attributes(id: list.id, cards: 1)
    end

    it "collapses every fork of one catalog list" do
      owner, fork = matched_pair
      other = deck_with("HSK 1", [word], create(:user))
      ids = [fork.word_list.id, other.word_list.id]

      report = collapse(owner)

      expect(report.collapsed.map(&:id)).to match_array(ids)
    end

    # Destroying a fork through an object loaded before the batch began takes
    # the *next* fork's repointed deck with it, so more than one fork has to
    # collapse for this to bite.
    it "keeps the deck of every fork in a multi-fork run" do
      owner, fork = matched_pair
      others = Array.new(2) { deck_with("HSK 1", [word], create(:user)) }
      ids = [fork.id, *others.map(&:id)]

      collapse(owner)

      expect(Deck.where(id: ids).count).to eq(3)
    end

    it "writes nothing on a dry run" do
      owner, fork = matched_pair
      list = fork.word_list

      described_class.call(owner:)

      expect(WordList.exists?(list.id)).to be(true)
    end

    it "reports what a dry run would collapse" do
      owner, fork = matched_pair

      report = described_class.call(owner:)

      expect(report.collapsed.map(&:id)).to eq([fork.word_list.id])
    end

    it "skips a list the owner holds no list of that name for" do
      row = skipped_row([word], [word], name: "Not In Catalog")

      expect(row)
        .to have_attributes(name: "Not In Catalog", reason: :no_catalog_match)
    end

    it "skips a fork whose glosses differ" do
      row = skipped_row([word], [word.merge(back: "to understand")])

      expect(row.reason).to eq(:content_differs)
    end

    it "skips a fork whose readings differ" do
      row = skipped_row([word.merge(reading: "míngbai")], [word])

      expect(row.reason).to eq(:content_differs)
    end

    it "skips a fork holding a word the catalog list does not" do
      row = skipped_row([word], [word, { front: "你好", back: "hi" }])

      expect(row.reason).to eq(:content_differs)
    end

    it "skips a fork missing a word the catalog list holds" do
      row = skipped_row([word, { front: "你好", back: "hi" }], [word])

      expect(row.reason).to eq(:content_differs)
    end

    it "leaves the owner's own lists alone" do
      owner = create(:user)
      deck_with("HSK 1", [word], owner)

      report = described_class.call(owner:)

      expect(report.collapsed + report.skipped).to be_empty
    end
  end
end
