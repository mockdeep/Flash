# frozen_string_literal: true

module ReadingMap
  # Gives each of a language's lists that isn't a level list its angle on
  # the reading map. Public lists are laid out by their links (Layout). A
  # private list then sits at the angle of the NEAR public lists it shares
  # the most less-common words with, the closer ones counting for more, and
  # moves nothing else; one that shares nothing with them goes in the
  # center. With no public list to go by, the private ones are spread
  # evenly in the order they were made. A list with no less-common words
  # gets no angle. Run it after Links. Returns a line per list, by angle,
  # then how many moved. A blank language means every one with such lists.
  module Angles
    NEAR = 3
    ENDS = [10.0, 170.0].freeze

    def self.call(language = nil)
      languages = [language.presence].compact.presence ||
        WordList.where(curriculum: false).distinct.pluck(:language).sort

      languages.flat_map { place(it) }
    end

    def self.place(language)
      words = Links.words(language)
      lists = WordList.where(id: words.keys).order(:id).to_a
      angles = angles(lists, words).transform_values { it.round(1) }
      moved = angles.count { |list, angle| move(list, angle) }
      name = WordList::LANGUAGES[language]

      [*lines(angles), "#{name}: #{angles.size} lists placed (#{moved} moved)"]
    end

    def self.move(list, angle)
      list.angle != angle && list.update!(angle:)
    end

    def self.lines(angles)
      angles.sort_by { |list, angle| [angle, list.id] }.map do |list, angle|
        "#{format("%5.1f", angle)}  #{list.name}"
      end
    end

    def self.angles(lists, words)
      open, hidden = lists.partition(&:publicly_visible?)
      links = WordListLink.where(word_list: open, linked_word_list: open)
      angles = Layout.call(open, links.to_a)
      return spread(hidden) if angles.empty?

      angles.merge(hidden.index_with { beside(it, angles, words) })
    end

    # The angle of the public lists nearest the private one in words.
    def self.beside(list, angles, words)
      near = nearest(list, angles.keys, words)
      total = near.sum(&:last)
      return Layout::CENTER if total.zero?

      near.sum { |other, strength| angles[other] * strength } / total
    end

    def self.nearest(list, others, words)
      shared =
        others.map do |other|
          [other, Links.strength(words[list.id], words[other.id])]
        end

      shared.max_by(NEAR) { |other, strength| [strength, -other.id] }
    end

    def self.spread(lists)
      return lists.index_with { Layout::CENTER } if lists.one?

      step = (ENDS.last - ENDS.first) / (lists.size - 1)
      lists.each_with_index.to_h do |list, index|
        [list, ENDS.first + (index * step)]
      end
    end
  end
end
