# frozen_string_literal: true

module ReadingMap
  # Works out the reading map's lines for a language: each public list
  # that isn't a level list is joined to the PER_LIST lists on its band or
  # further out that it shares the most less-common words with. A pair's
  # strength is the senses both hold out of those either holds, leaving out
  # every word of the lowest COMMON_LEVELS levels, which all texts share.
  # There is no least strength, so a faint line shows where texts are
  # missing; lists that share nothing get none. A match two stronger ones
  # already join through a third list is left out (a backbone's first
  # version to its third, with the second between), so the lines of a
  # chain don't run along each other. Each run replaces the
  # language's links, keeping the row of a pair that still stands. Returns a
  # line per list with its matches, then what changed. A blank language
  # means every one with a public list.
  module Links
    PER_LIST = 3
    COMMON_LEVELS = 2
    HEADWORD = "LOWER(entries.headword)"

    def self.call(language = nil)
      languages = [language.presence].compact.presence ||
        WordList.where(visibility: "public").distinct.pluck(:language).sort

      languages.flat_map { link(it) }
    end

    def self.link(language)
      words = words(language, WordList.where(visibility: "public"))
      lists = WordList.where(id: words.keys).order(:id).to_a
      matches = uncovered(lists.index_with { strongest(it, lists, words) })

      lines = matches.map { |list, found| line(list, found) }
      [*lines, save(language, matches)]
    end

    # The less-common senses of each of the language's lists that isn't a
    # level list, by its id; a list with none is left out.
    def self.words(language, lists = WordList.all)
      lists = lists.where(language:, curriculum: false)
      pairs = SenseMembership.joins(sense: :entry).where(word_list: lists)
        .where.not("#{HEADWORD} IN (?)", common(language))
        .pluck(:word_list_id, :sense_id)

      pairs.group_by(&:first).transform_values { it.to_set(&:last) }
    end

    # The headwords of the language's lowest level lists.
    def self.common(language)
      level_lists = WordList.where(language:, curriculum: true)
      lowest = level_lists.where.not(level: nil).distinct.order(:level)
        .limit(COMMON_LEVELS).pluck(:level)

      Entry.joins(senses: { sense_memberships: :word_list })
        .merge(level_lists.where(level: lowest)).select(HEADWORD)
    end

    # The list's closest matches on its band or further out, strongest
    # first, each with its strength.
    def self.strongest(list, lists, words)
      outward = lists.select { it != list && band(it) >= band(list) }
      matches = outward.map { [it, strength(words[list.id], words[it.id])] }

      matches.select { |_, strength| strength.positive? }
        .max_by(PER_LIST) { |other, strength| [strength, -other.id] }
    end

    # The matches without any that two stronger ones already join through
    # a third list.
    def self.uncovered(matches)
      pairs = pairs(matches)

      matches.to_h do |list, found|
        kept = found.reject { |other, at| covered?(pairs, list, other, at) }
        [list, kept]
      end
    end

    def self.covered?(pairs, list, other, strength)
      stronger = pairs.select { |_, at| at > strength }.keys

      stronger.flatten.uniq.any? do |via|
        stronger.include?([list.id, via].sort) &&
          stronger.include?([via, other.id].sort)
      end
    end

    # A language with no level lists has one band.
    def self.band(list) = list.level || 0

    def self.strength(words, others)
      (words & others).size.fdiv((words | others).size).round(4)
    end

    def self.line(list, matches)
      found =
        matches.map do |other, strength|
          "#{other.name} #{(strength * 100).round}%"
        end

      "#{list.name}: #{found.join(", ").presence || "no links"}"
    end

    def self.save(language, matches)
      pairs = pairs(matches)
      links = WordListLink.joins(:word_list).where(word_lists: { language: })
        .index_by { [it.word_list_id, it.linked_word_list_id] }

      counts = WordListLink.transaction { replace(links, pairs) }
      "#{WordList::LANGUAGES[language]}: #{pairs.size} links " \
        "(#{counts.map { |kind, count| "#{count} #{kind}" }.join(", ")})"
    end

    # Each joined pair once, lower id first, with its strength.
    def self.pairs(matches)
      matches.each_with_object({}) do |(list, found), pairs|
        found.each do |other, strength|
          pairs[[list.id, other.id].sort] = strength
        end
      end
    end

    def self.replace(links, pairs)
      removed = links.except(*pairs.keys).each_value(&:destroy!)
      kept = links.slice(*pairs.keys)
      changed = kept.count { |ids, link| restrengthen(link, pairs[ids]) }
      added = pairs.except(*links.keys).each { |ids, at| add(ids, at) }

      { added: added.size, changed:, removed: removed.size }
    end

    def self.restrengthen(link, strength)
      link.strength != strength && link.update!(strength:)
    end

    def self.add(ids, strength)
      WordListLink.create!(
        word_list_id: ids.first, linked_word_list_id: ids.last, strength:,
      )
    end
  end
end
