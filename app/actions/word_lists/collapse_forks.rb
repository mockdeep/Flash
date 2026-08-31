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
  # `owner` is the account whose lists are canonical - every other account's
  # list is a fork, and collapses onto the owner's list of the same name and
  # language. Deck visibility does not identify the canonical set: several of
  # the catalog's own decks are unpublished, and their lists would then read
  # as forks of nothing.
  #
  # `accept_gloss_drift` widens the gate to fronts and readings alone, for the
  # forks that hold the same words under an older generation's wording. Those
  # users end up on the canonical gloss, which is the point of the model - one
  # wording per word - and the flag cannot reach further than intended, since
  # every other remaining fork differs in its *fronts*.
  #
  # The dry run reports over the same code path that writes, so the report
  # cannot drift from the thing it verifies:
  #
  #   owner = User.find(1)
  #   WordLists::CollapseForks.call(owner:)             # writes nothing
  #   WordLists::CollapseForks.call(owner:, dry_run: false)
  #   WordLists::CollapseForks.call(owner:, accept_gloss_drift: true)
  module CollapseForks
    extend self

    Report = Data.define(:collapsed, :skipped)
    Collapsed = Data.define(:id, :name, :language, :catalog_id, :cards)
    Skipped = Data.define(:id, :name, :language, :reason)

    def call(owner:, dry_run: true, accept_gloss_drift: false)
      results =
        forks(owner).map do |fork|
          process(owner, fork, dry_run:, accept_gloss_drift:)
        end
      collapsed, skipped =
        results.partition { |result| result.is_a?(Collapsed) }
      Report.new(collapsed:, skipped:)
    end

    private

    def process(owner, fork, dry_run:, accept_gloss_drift:)
      catalog = counterpart(owner, fork)
      reason = skip_reason(fork, catalog, accept_gloss_drift:)
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
      discard(fork)
      count
    end

    # Destroying the list through the object the run has been holding deletes
    # live decks. `WordList has_many :decks, dependent: :destroy`, and once any
    # fork in the batch has been destroyed the remaining fork objects carry a
    # *loaded* decks association whose target still holds each deck as it was
    # before the repoint - so the cascade destroys a deck (and its cards) that
    # now belongs to the catalog list, while the database says nothing points
    # at the fork. Re-reading the row asks the database instead, and its
    # cascade finds nothing left to take.
    def discard(fork)
      WordList.find(fork.id).destroy!
    end

    # Every front the gate compared has a counterpart, so a card can only miss
    # one by anchoring something the comparison never saw. `update!` then
    # fails on the card's item presence rule and takes the whole fork's
    # transaction with it, rather than destroying items a card still needs.
    def relink_cards(fork, targets)
      cards = Card.where(item_id: fork.items.select(:id))
      count = cards.count
      cards.includes(:item).find_each do |card|
        card.update!(item: targets[key(card.item)])
      end
      count
    end

    # Moved by query rather than through `fork.decks`, so the word_list's
    # `dependent: :destroy` cannot find a cached copy of decks that have just
    # stopped belonging to it.
    def repoint_decks(fork, catalog)
      Deck.where(word_list_id: fork.id).find_each do |deck|
        deck.update!(word_list: catalog)
      end
    end

    def skip_reason(fork, catalog, accept_gloss_drift:)
      return :no_catalog_match unless catalog

      fork_signature = signature(fork, accept_gloss_drift:)
      catalog_signature = signature(catalog, accept_gloss_drift:)
      return :content_differs unless fork_signature == catalog_signature

      nil
    end

    # Fronts, their readings, and the glosses each one displays - the whole of
    # what a card shows. Comparing two of these settles both directions at
    # once: a word or gloss on either side alone makes the hashes differ.
    #
    # Built from plucked columns rather than loaded records, because the
    # catalog's largest lists run to thousands of fronts and instantiating
    # each one with its pairings and back items is more than a console dyno
    # holds.
    # Accepting gloss drift leaves every value empty, so the comparison falls
    # back to the fronts and readings the hash is keyed on.
    def signature(word_list, accept_gloss_drift:)
      fronts = front_items(word_list).pluck(:id, :text, :reading)
      glosses =
        accept_gloss_drift ? {} : glosses_by_front(fronts.map(&:first))
      fronts.to_h { |id, text, reading| [[text, reading], glosses[id].to_a] }
    end

    # Back-item texts per front, in authored order (pairing id) - the order
    # Item#glosses reads them in, and the order a card displays.
    def glosses_by_front(front_ids)
      pairings = Pairing.where(item_id: front_ids)
        .order(:id)
        .pluck(:item_id, :paired_item_id)
      texts = Item.where(id: pairings.map(&:last)).pluck(:id, :text).to_h
      pairings.group_by(&:first)
        .transform_values { |rows| rows.map { |row| texts[row.last] } }
    end

    def front_items(word_list)
      Item.where(word_list_id: word_list.id, side: Projection::FRONT)
    end

    def key(item) = [item.text, item.reading]

    def forks(owner)
      WordList.where.not(user_id: owner.id).order(:id)
    end

    def counterpart(owner, fork)
      WordList.find_by(
        user_id: owner.id, name: fork.name, language: fork.language,
      )
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
