# frozen_string_literal: true

module WordLists
  # The last of phase 4's fork collapse (docs/compendium.md), for the forks
  # that copied an older, larger generation of the HSK catalog. They cannot
  # collapse like the others: they store no readings, and the level boundaries
  # have since been redrawn under them, so most of their words are published
  # at a different level today.
  #
  # Rather than shrink such a deck to the handful of words that stayed put,
  # this moves it wholesale onto the current canonical list. Cards are matched
  # to the catalog's items **by text alone** - the missing readings are the
  # whole reason these lists are stuck - so progress survives on every word
  # the catalog still publishes at that level. Cards for words it no longer
  # does are dropped, and the words the fork never had are added, leaving an
  # ordinary deck over the catalog list.
  #
  # Takes explicit ids, because unlike the other collapses it deletes cards:
  #
  #   owner = User.find(1)
  #   WordLists::AdoptCatalogList.call(owner:, ids: [56, 61, 68, 81])
  #   WordLists::AdoptCatalogList.call(owner:, ids: [...], dry_run: false)
  module AdoptCatalogList
    extend self

    Report = Data.define(:adopted, :skipped)
    Adopted = Data.define(:id, :name, :relinked, :dropped, :added)
    Skipped = Data.define(:id, :name, :reason)

    def call(owner:, ids:, dry_run: true)
      results =
        WordList.where(id: ids).order(:id).map do |fork|
          process(owner, fork, dry_run:)
        end
      adopted, skipped = results.partition { |result| result.is_a?(Adopted) }
      Report.new(adopted:, skipped:)
    end

    private

    # The owner check comes first: one of the owner's own lists would find
    # itself as its counterpart and be adopted onto itself.
    def process(owner, fork, dry_run:)
      return skipped(fork, :owner_list) if fork.user_id == owner.id

      catalog = counterpart(owner, fork)
      return skipped(fork, :no_catalog_match) unless catalog

      adopt(fork, catalog, dry_run:)
    end

    def adopt(fork, catalog, dry_run:)
      counts = nil
      ActiveRecord::Base.transaction do
        counts = move(fork, catalog)
        raise ActiveRecord::Rollback if dry_run
      end
      Adopted.new(id: fork.id, name: fork.name, **counts)
    end

    # Deck ids are taken before anything moves; afterwards the fork has no
    # decks to find.
    def move(fork, catalog)
      decks = Deck.where(word_list_id: fork.id).ids
      relinked, dropped = resettle_cards(fork, front_items(catalog))
      repoint(decks, catalog)
      added = fill(decks)
      discard(fork)
      { relinked:, dropped:, added: }
    end

    def resettle_cards(fork, catalog_fronts)
      targets = catalog_fronts.index_by(&:text)
      cards = Card.where(item_id: fork.items.select(:id)).includes(:item)
      outcomes = cards.find_each.map { |card| resettle(card, targets) }
      [outcomes.count(:relinked), outcomes.count(:dropped)]
    end

    # A card whose word the catalog still carries keeps its counters on the
    # catalog's item; one whose word has moved to another level has nowhere to
    # go here, and goes.
    def resettle(card, targets)
      target = targets[card.item.text]
      unless target
        card.destroy!
        return :dropped
      end

      card.update!(item: target)
      :relinked
    end

    def repoint(decks, catalog)
      Deck.where(id: decks).find_each do |deck|
        deck.update!(word_list: catalog)
      end
    end

    # The catalog's remaining words become new cards, so each deck ends up as
    # the canonical deck rather than a subset of it.
    def fill(decks)
      Deck.where(id: decks).sum do |deck|
        before = deck.cards.count
        Projection.build_cards(deck)
        deck.cards.count - before
      end
    end

    # Re-read before destroying: a list object held since the batch began can
    # carry a stale decks association, and the cascade would take live decks.
    def discard(fork)
      WordList.find(fork.id).destroy!
    end

    def front_items(word_list)
      Item.where(word_list_id: word_list.id, side: Projection::FRONT)
    end

    def counterpart(owner, fork)
      WordList.find_by(
        user_id: owner.id, name: fork.name, language: fork.language,
      )
    end

    def skipped(fork, reason)
      Skipped.new(id: fork.id, name: fork.name, reason:)
    end
  end
end
