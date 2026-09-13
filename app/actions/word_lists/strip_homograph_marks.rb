# frozen_string_literal: true

module WordLists
  # Phase 4's second pre-rung (docs/compendium.md). The Mandarin catalog marked
  # the less common reading of a same-level homograph with a tone superscript
  # or its reading in parens, only to satisfy items' old unique index. The
  # index now includes the reading, so the marks come off and study tells the
  # twins apart instead.
  #
  # A front is stripped only when its parens hold its own reading and a twin
  # with the bare front already sits in the same list; anything else that
  # looks marked is reported and left alone.
  #
  #   WordLists::StripHomographMarks.call              # writes nothing
  #   WordLists::StripHomographMarks.call(dry_run: false)
  module StripHomographMarks
    extend self

    MARK = /\A(?<base>.+?)(?:[⁰¹²³⁴]|\s+\((?<reading>[^)]+)\))\z/

    Report = Data.define(:stripped, :skipped)
    Stripped = Data.define(:id, :word_list, :from, :to, :reading)
    Skipped = Data.define(:id, :word_list, :text, :reason)

    def call(dry_run: true)
      results = marked_items.map { |item, match| plan(item, match) }
      stripped, skipped = results.partition { |row| row.is_a?(Stripped) }
      ActiveRecord::Base.transaction do
        stripped.each { |row| Item.find(row.id).update!(text: row.to) }
        raise ActiveRecord::Rollback if dry_run
      end
      Report.new(stripped:, skipped:)
    end

    private

    def plan(item, match)
      if match[:reading] && match[:reading] != item.reading
        return skipped(item, :reading_mismatch)
      end
      return skipped(item, :no_twin) unless twin?(item, match[:base])

      stripped(item, match[:base])
    end

    def marked_items
      Item.joins(:word_list).includes(:word_list).order(:id)
        .where(side: Projection::FRONT, word_lists: { language: "zh" })
        .filter_map { |item| MARK.match(item.text)&.then { [item, it] } }
    end

    def twin?(item, text)
      Item
        .where(word_list_id: item.word_list_id, side: Projection::FRONT, text:)
        .where.not(reading: item.reading)
        .exists?
    end

    def stripped(item, text)
      Stripped.new(
        id: item.id,
        word_list: item.word_list.name,
        from: item.text,
        to: text,
        reading: item.reading,
      )
    end

    def skipped(item, reason)
      Skipped.new(
        id: item.id,
        word_list: item.word_list.name,
        text: item.text,
        reason:,
      )
    end
  end
end
