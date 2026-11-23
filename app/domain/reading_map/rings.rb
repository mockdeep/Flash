# frozen_string_literal: true

module ReadingMap
  # A language's rings on the reading map, counted outward from 1: one per
  # level its level lists have, then one more past the top level for lists
  # beyond it. A language with no level lists has a single ring.
  class Rings
    def initialize(language)
      @language = language
    end

    def count = levels.any? ? levels.size + 1 : 1

    # The level lists, lowest level first.
    def level_lists
      @level_lists ||= WordList.where(language: @language, curriculum: true)
        .where.not(level: nil).order(:level, :id).to_a
    end

    def levels = @levels ||= level_lists.map(&:level).uniq

    # The ring a list sits on. One with no level in a language that has
    # them hasn't been placed yet, so it waits past the last.
    def of(list)
      return 1 if levels.empty?

      levels.index(list.level)&.succ || count
    end
  end
end
