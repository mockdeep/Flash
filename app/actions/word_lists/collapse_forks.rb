# frozen_string_literal: true

module WordLists
  # Phase 4's first pre-rung (docs/compendium.md): collapses forked word_lists
  # onto the catalog list they were copied from, so the entries backfill sees
  # one row per word rather than a copy per user. A fork collapses only when
  # its fronts, readings, and glosses match the catalog list exactly - that
  # gate is what makes the change invisible to whoever studies it. Cards are
  # relinked rather than rebuilt, so they keep their ids and their progress
  # counters, and a fork's items are destroyed only once no card points at
  # them.
  #
  # The dry run reports over the same code path that writes, so the report
  # cannot drift from the thing it verifies:
  #
  #   WordLists::CollapseForks.call             # dry run, writes nothing
  #   WordLists::CollapseForks.call(dry_run: false)
  module CollapseForks
    extend self

    Report = Data.define(:collapsed, :skipped)
    Collapsed = Data.define(:id, :name, :language, :catalog_id, :cards)
    Skipped = Data.define(:id, :name, :language, :reason)

    def call(dry_run: true)
      results = forks.map { |fork| process(fork, dry_run:) }
      collapsed, skipped =
        results.partition { |result| result.is_a?(Collapsed) }
      Report.new(collapsed:, skipped:)
    end

    private

    def process(fork, dry_run:)
      catalog = counterpart(fork)
      reason = skip_reason(fork, catalog)
      return skipped(fork, reason) if reason

      cards = nil
      ActiveRecord::Base.transaction do
        cards = collapse(fork, catalog)
        raise ActiveRecord::Rollback if dry_run
      end
      collapsed(fork, catalog, cards)
    end

    def collapse(fork, catalog)
      targets = front_items(catalog).index_by { |item| key(item) }
      count = relink_cards(fork, targets)
      repoint_decks(fork, catalog)
      fork.destroy!
      count
    end

    # Every front the gate compared has a counterpart, so a card can only miss
    # one by anchoring something the comparison never saw. `update!` then
    # fails on the card's item presence rule and takes the whole fork's
    # transaction with it, rather than destroying items a card still needs.
    def relink_cards(fork, targets)
      cards = Card.where(item_id: fork.items.select(:id)).includes(:item).load
      cards.each { |card| card.update!(item: targets[key(card.item)]) }
      cards.size
    end

    # Moved by query rather than through `fork.decks`, so the word_list's
    # `dependent: :destroy` cannot find a cached copy of decks that have just
    # stopped belonging to it.
    def repoint_decks(fork, catalog)
      Deck.where(word_list_id: fork.id).find_each do |deck|
        deck.update!(word_list: catalog)
      end
    end

    def skip_reason(fork, catalog)
      return :no_catalog_match unless catalog
      return :content_differs unless signature(fork) == signature(catalog)

      nil
    end

    # Fronts, their readings, and the glosses each one displays - the whole of
    # what a card shows. Comparing two of these settles both directions at
    # once: a word or gloss on either side alone makes the hashes differ.
    def signature(word_list)
      front_items(word_list).to_h { |item| [key(item), item.glosses] }
    end

    def front_items(word_list)
      word_list.items
        .where(side: Projection::FRONT)
        .includes(pairings: :paired_item)
    end

    def key(item) = [item.text, item.reading]

    def forks
      WordList.where.not(id: catalog_list_ids).order(:id)
    end

    def counterpart(fork)
      WordList
        .where(id: catalog_list_ids)
        .find_by(name: fork.name, language: fork.language)
    end

    # Public decks are the catalog, and their word_lists are what forks
    # collapse onto. Flat-card decks carry no word_list, and a NULL inside the
    # subquery would leave `where.not(id: ...)` matching nothing at all.
    def catalog_list_ids
      Deck.publicly_visible.where.not(word_list_id: nil).select(:word_list_id)
    end

    def collapsed(fork, catalog, cards)
      Collapsed.new(
        id: fork.id,
        name: fork.name,
        language: fork.language,
        catalog_id: catalog.id,
        cards:,
      )
    end

    def skipped(fork, reason)
      Skipped.new(
        id: fork.id, name: fork.name, language: fork.language, reason:,
      )
    end
  end
end
