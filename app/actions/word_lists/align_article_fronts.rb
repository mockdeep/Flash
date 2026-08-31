# frozen_string_literal: true

module WordLists
  # A one-off pre-step for phase 4's fork collapse (docs/compendium.md). Three
  # "Spanish A1 Vocab" forks hold exactly the catalog's words under an older
  # spelling: bare nouns where the catalog now writes "el pelo", and
  # "el/la cantante" for common gender. Rewriting their fronts to the catalog
  # spelling lets an ordinary `CollapseForks` run match them, so no
  # language-specific rule has to live in that general action.
  #
  # Only a fork whose words are identical to the catalog list once articles
  # are stripped qualifies; everything else is reported and left alone, which
  # is what keeps this off the forks that differ in actual vocabulary.
  #
  #   owner = User.find(1)
  #   WordLists::AlignArticleFronts.call(owner:)              # writes nothing
  #   WordLists::AlignArticleFronts.call(owner:, dry_run: false)
  module AlignArticleFronts
    extend self

    ARTICLE = %r{\A(?:el/la|el|la|los|las|un|una)\s+}i

    Report = Data.define(:aligned, :skipped)
    Aligned = Data.define(:id, :name, :renamed, :dropped)
    Skipped = Data.define(:id, :name, :reason)
    Move = Data.define(:text, :keeper, :extras)

    def call(owner:, dry_run: true)
      results = forks(owner).map { |fork| process(owner, fork, dry_run:) }
      aligned, skipped = results.partition { |result| result.is_a?(Aligned) }
      Report.new(aligned:, skipped:)
    end

    private

    def process(owner, fork, dry_run:)
      catalog = counterpart(owner, fork)
      return skipped(fork, :no_catalog_match) unless catalog

      moves = plan(fork, catalog)
      return skipped(fork, :words_differ) unless moves

      apply(fork, moves, dry_run:)
    end

    # One move per word: the catalog's spelling, the fork item that will carry
    # it, and any duplicate spellings of the same word to discard. Nil unless
    # the two lists hold the same words once articles are stripped.
    def plan(fork, catalog)
      seed = canonical_fronts(catalog)
      groups = front_items(fork).group_by { |item| strip(item.text) }
      return unless groups.keys.sort == seed.keys.sort

      groups.map { |key, items| move_for(seed[key], items) }
    end

    def canonical_fronts(catalog)
      front_items(catalog).pluck(:text).index_by { |text| strip(text) }
    end

    def move_for(text, items)
      keeper, *extras = ranked(items)
      Move.new(text:, keeper:, extras:)
    end

    def apply(fork, moves, dry_run:)
      renamed = moves.count { |move| move.keeper.text != move.text }
      dropped = moves.sum { |move| move.extras.size }
      ActiveRecord::Base.transaction do
        moves.each { |move| perform(move) }
        raise ActiveRecord::Rollback if dry_run
      end
      Aligned.new(id: fork.id, name: fork.name, renamed:, dropped:)
    end

    # Duplicates go before the rename, or the two spellings would collide on
    # items' unique (word_list_id, side, text). Their cards go with them,
    # which is the intent: one word, one card in a deck. The row is re-read so
    # the cascade reads the database rather than an association loaded earlier
    # in the run.
    def perform(move)
      move.extras.each { |item| Item.find(item.id).destroy! }
      move.keeper.update!(text: move.text) if move.keeper.text != move.text
    end

    # Of two spellings of one word, the better-studied card's item stays.
    def ranked(items)
      return items if items.one?

      items.sort_by { |item| [-progress(item), item.id] }
    end

    def progress(item)
      cards = Card.where(item:)
      cards.sum(:correct_count) + cards.sum(:view_count)
    end

    def strip(text) = text.downcase.sub(ARTICLE, "")

    def front_items(word_list)
      Item.where(word_list_id: word_list.id, side: Projection::FRONT)
    end

    def forks(owner)
      WordList.where.not(user_id: owner.id).order(:id)
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
