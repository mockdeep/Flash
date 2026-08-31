# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::CollapseForks do
  def word
    { front: "明白", back: "understand" }
  end

  def deck_with(name, cards, visibility)
    deck = create(:reading_deck, name:, user: create(:user), visibility:)
    cards.each { |attrs| create(:reading_card, deck:, **attrs) }
    deck
  end

  def catalog_deck(cards, name: "HSK 1")
    deck_with(name, cards, "public")
  end

  def fork_deck(cards, name: "HSK 1")
    deck_with(name, cards, "private")
  end

  # A catalog deck and a private copy of it, byte-identical: the case the
  # first PR collapses. Returns the copier's deck.
  def matched_fork
    catalog_deck([word])
    fork_deck([word])
  end

  def catalog_list
    Deck.publicly_visible.sole.word_list
  end

  def catalog_front
    catalog_list.items.find_by(text: word[:front])
  end

  # Builds a catalog deck and a fork beside it, then reports on the fork.
  # Every gate example differs only in the content of the two.
  def skipped_row(catalog_cards, fork_cards, name: "HSK 1")
    catalog_deck(catalog_cards)
    fork_deck(fork_cards, name:)
    described_class.call.skipped.sole
  end

  describe ".call" do
    it "relinks the fork's cards onto the catalog items" do
      card = matched_fork.cards.sole

      described_class.call(dry_run: false)

      expect(card.reload.item).to eq(catalog_front)
    end

    it "keeps the relinked card's progress counters" do
      card = matched_fork.cards.sole
      card.update!(correct_count: 4, correct_streak: 2, view_count: 9)

      described_class.call(dry_run: false)

      expect(card.reload)
        .to have_attributes(correct_count: 4, correct_streak: 2, view_count: 9)
    end

    it "repoints the fork's deck at the catalog list" do
      deck = matched_fork

      described_class.call(dry_run: false)

      expect(deck.reload.word_list).to eq(catalog_list)
    end

    it "destroys the emptied fork word_list" do
      list = matched_fork.word_list

      described_class.call(dry_run: false)

      expect(WordList.exists?(list.id)).to be(false)
    end

    it "reports the collapsed list" do
      list = matched_fork.word_list

      report = described_class.call(dry_run: false)

      expect(report.collapsed.sole)
        .to have_attributes(id: list.id, catalog_id: catalog_list.id, cards: 1)
    end

    it "collapses every fork of one catalog list" do
      catalog_deck([word])
      lists = [fork_deck([word]).word_list, fork_deck([word]).word_list]

      report = described_class.call(dry_run: false)

      expect(report.collapsed.map(&:id)).to match_array(lists.map(&:id))
    end

    it "writes nothing on a dry run" do
      list = matched_fork.word_list

      described_class.call

      expect(WordList.exists?(list.id)).to be(true)
    end

    it "reports what a dry run would collapse" do
      list = matched_fork.word_list

      report = described_class.call

      expect(report.collapsed.map(&:id)).to eq([list.id])
    end

    it "skips a list no catalog deck shares a name with" do
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

    it "leaves catalog lists alone" do
      catalog_deck([word])

      report = described_class.call

      expect(report.collapsed + report.skipped).to be_empty
    end
  end
end
