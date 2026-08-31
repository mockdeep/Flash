# frozen_string_literal: true

require "rails_helper"

RSpec.describe WordLists::AlignArticleFronts do
  def deck_with(name, cards, user)
    deck = create(:reading_deck, name:, user:, language: "es")
    cards.each { |attrs| create(:reading_card, deck:, **attrs) }
    deck
  end

  # A catalog list and another account's copy under the same name.
  # Returns the catalog's owner and the copier's deck.
  def pair(catalog_cards, fork_cards, name: "Spanish A1")
    owner = create(:user)
    deck_with("Spanish A1", catalog_cards, owner)
    [owner, deck_with(name, fork_cards, create(:user))]
  end

  # The real case: the catalog articles its nouns, the fork does not.
  def article_pair
    pair(
      [{ front: "el pelo", back: "hair" }],
      [{ front: "pelo", back: "hair" }],
    )
  end

  def gender_pair
    pair(
      [{ front: "el/la cantante", back: "singer" }],
      [{ front: "cantante", back: "singer" }],
    )
  end

  def matching_pair
    pair(
      [{ front: "el menú", back: "menu" }],
      [{ front: "el menú", back: "menu" }],
    )
  end

  def other_words_pair
    pair(
      [{ front: "el pelo", back: "hair" }],
      [{ front: "la nariz", back: "nose" }],
    )
  end

  # The stray "centro" beside "el centro": both strip to the same word, so
  # after the rename they would collide. Only the studied one may survive.
  def duplicate_pair
    owner, fork = pair(
      [{ front: "el centro", back: "centre" }],
      [{ front: "el centro", back: "centre" }, { front: "centro", back: "c" }],
    )
    studied = fork.word_list.items.find_by(text: "el centro")
    fork.cards.find_by(item: studied).update!(view_count: 12)
    [owner, fork]
  end

  def align(owner)
    described_class.call(owner:, dry_run: false)
  end

  describe ".call" do
    it "renames a bare front to the catalog spelling" do
      owner, fork = article_pair

      align(owner)

      expect(fork.cards.sole.reload.front).to eq("el pelo")
    end

    it "keeps the card's progress through the rename" do
      owner, fork = article_pair
      fork.cards.sole.update!(correct_count: 3, view_count: 8)

      align(owner)

      expect(fork.cards.sole.reload)
        .to have_attributes(correct_count: 3, view_count: 8)
    end

    it "matches common-gender spellings" do
      owner, fork = gender_pair

      align(owner)

      expect(fork.cards.sole.reload.front).to eq("el/la cantante")
    end

    it "leaves a front that already matches" do
      owner, = matching_pair

      report = described_class.call(owner:)

      expect(report.aligned.sole).to have_attributes(renamed: 0, dropped: 0)
    end

    it "drops the duplicate spelling, keeping the studied one" do
      owner, fork = duplicate_pair

      align(owner)

      expect(fork.cards.sole.reload.front).to eq("el centro")
    end

    it "keeps the studied card's history when dropping its duplicate" do
      owner, fork = duplicate_pair

      align(owner)

      expect(fork.cards.sole.reload.view_count).to eq(12)
    end

    it "reports what it renamed and dropped" do
      owner, fork = duplicate_pair

      report = align(owner)

      expect(report.aligned.sole)
        .to have_attributes(id: fork.word_list.id, renamed: 0, dropped: 1)
    end

    it "writes nothing on a dry run" do
      owner, fork = article_pair

      described_class.call(owner:)

      expect(fork.cards.sole.reload.front).to eq("pelo")
    end

    it "skips a fork whose words differ beyond articles" do
      owner, = other_words_pair

      report = described_class.call(owner:)

      expect(report.skipped.sole.reason).to eq(:words_differ)
    end

    it "skips a fork the owner holds no list of that name for" do
      owner, = article_pair
      stray = [{ front: "pelo", back: "hair" }]
      deck_with("Not In Catalog", stray, create(:user))

      report = described_class.call(owner:)

      expect(report.skipped.sole.reason).to eq(:no_catalog_match)
    end

    it "leaves the owner's own lists alone" do
      owner = create(:user)
      deck_with("Spanish A1", [{ front: "el pelo", back: "hair" }], owner)

      report = described_class.call(owner:)

      expect(report.aligned + report.skipped).to be_empty
    end
  end
end
