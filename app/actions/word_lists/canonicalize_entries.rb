# frozen_string_literal: true

module WordLists
  # Phase 4's first rung (docs/compendium.md, 4.1). Every Front item becomes a
  # pointer at an entry: one per distinct (language, headword, reading)
  # across all word_lists, so a word taught by two lists is one row. The
  # dedup relies on the entries index treating NULL readings as equal, since
  # only Mandarin carries readings.
  #
  # Idempotent: entries that already exist are skipped and items already
  # linked are left alone, so a rerun after a partial run finishes the job.
  #
  #   WordLists::CanonicalizeEntries.call              # writes nothing
  #   WordLists::CanonicalizeEntries.call(dry_run: false)
  module CanonicalizeEntries
    extend self

    # `unlinked` and `mismatched` must both be 0 after a run; `merged` counts
    # entries shared by more than one Front item, per language.
    Report = Data.define(:entries, :linked, :unlinked, :mismatched, :merged)

    LINK = <<~SQL.squish
      UPDATE items
      SET entry_id = entries.id
      FROM word_lists, entries
      WHERE items.word_list_id = word_lists.id
        AND items.side = 'Front'
        AND items.entry_id IS NULL
        AND entries.language = word_lists.language
        AND entries.headword = items.text
        AND entries.reading IS NOT DISTINCT FROM items.reading
    SQL

    def call(dry_run: true)
      report = nil
      ActiveRecord::Base.transaction do
        report = perform
        raise ActiveRecord::Rollback if dry_run
      end
      report
    end

    private

    def perform
      entries = insert_entries
      linked = ActiveRecord::Base.connection.update(LINK)
      Report.new(
        entries:,
        linked:,
        unlinked: fronts.where(entry_id: nil).count,
        mismatched: mismatched.count,
        merged:,
      )
    end

    # Rows that collide with an existing entry are skipped, which is what
    # makes a rerun safe.
    def insert_entries
      before = Entry.count
      rows = words
      Entry.insert_all(rows) if rows.any?
      Entry.count - before
    end

    def words
      fronts.joins(:word_list).distinct
        .pluck("word_lists.language", :text, :reading)
        .map { |row| [:language, :headword, :reading].zip(row).to_h }
    end

    def fronts
      Item.where(side: Projection::FRONT)
    end

    def mismatched
      fronts.joins(:entry).where.not(
        "entries.headword = items.text " \
        "AND entries.reading IS NOT DISTINCT FROM items.reading",
      )
    end

    def merged
      shared = fronts.group(:entry_id).having("COUNT(*) > 1").select(:entry_id)
      Entry.where(id: shared).group(:language).count
    end
  end
end
