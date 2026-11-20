# frozen_string_literal: true

module ReadingMap
  # Gives each word list that has no `level` its band on the reading map:
  # the lowest level whose lists, with those below, hold COVERED of its
  # words, or one past the top level when none does. Level lists
  # (`curriculum`) and backbone versions are given theirs by hand, and a
  # level once set stays, so a list keeps its band as its source grows;
  # clearing one has the next run work it out again. A language with no
  # level lists has no bands, so its lists get none. Returns a line per
  # list placed, with the share each level covers.
  module Levels
    COVERED = 0.8

    # A level with the words its lists and those below hold, and in a
    # language written without spaces their characters, since the lists
    # hold some characters only inside longer words.
    Band = Data.define(:level, :words, :characters)

    class Band
      def holds?(word)
        words.include?(word) ||
          (word.length == 1 && characters.include?(word))
      end

      # The share of the words the band holds, each in any of its
      # spellings.
      def share(words)
        held =
          words.count do |spellings|
            spellings.any? { |forms| forms.all? { holds?(it) } }
          end
        held.fdiv(words.size)
      end
    end

    # A blank language means every one with level lists.
    def self.call(language = nil)
      languages = [language.presence].compact.presence ||
        leveled.distinct.pluck(:language).sort

      languages.flat_map { place(it) }
    end

    def self.leveled = WordList.where(curriculum: true).where.not(level: nil)

    def self.place(language)
      name = WordList::LANGUAGES[language]
      unplaced = WordList.where(language:, level: nil).order(:id)
      level_list = unplaced.find_by(curriculum: true)
      return ["#{name}: #{level_list.name} has no level"] if level_list

      bands = bands(language)
      return ["#{name}: no level lists"] if bands.empty?

      unplaced.filter_map { |list| place_list(list, bands) }
    end

    def self.place_list(list, bands)
      words = ListWords.call(list, known: bands.last.words)
      return if words.empty?

      shares = bands.map { it.share(words) }
      list.update!(level: level(bands, shares))

      "#{list.name}: level #{list.level} (#{percents(shares)})"
    end

    def self.level(bands, shares)
      covering = shares.index { it >= COVERED }

      covering ? bands[covering].level : bands.last.level + 1
    end

    def self.percents(shares) = shares.map { "#{(it * 100).floor}%" }.join(" ")

    # The language's bands from the lowest level up.
    def self.bands(language)
      spaced = Language.supported?(language) && Language.for(language).spaces
      words = Set.new

      headwords(language).sort.map do |level, listed|
        words |= listed
        characters = spaced ? Set.new : words.flat_map(&:chars).to_set
        Band.new(level:, words:, characters:)
      end
    end

    # Each level's own headwords, in lower case.
    def self.headwords(language)
      pairs = Entry.joins(senses: { sense_memberships: :word_list })
        .merge(leveled.where(language:)).distinct
        .pluck("word_lists.level", "LOWER(entries.headword)")

      pairs.group_by(&:first).transform_values { it.map(&:last) }
    end
  end
end
