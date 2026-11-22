# frozen_string_literal: true

module ReadingMap
  # Where a language's public lists point on the map's half ring, from 0
  # degrees at one end through CENTRE to 180 at the other. Lists joined by
  # a STRONG link make a group and share an angle, so a backbone's versions
  # run outward as one spoke. The group with the most lists goes up the
  # centre. Every other group sits to one side: nearer the centre the more
  # strongly its lists are linked to the centre group's, from NEAREST
  # degrees off for the closest to FURTHEST for one with no link to it. A
  # group keeps the side its lists are stored on, so a run never flips the
  # map; a new one takes the side of the group it is most linked to, or
  # else the emptier side, the lower angles first.
  class Layout
    CENTRE = 90.0
    STRONG = 0.2
    NEAREST = 20.0
    FURTHEST = 80.0
    SIDES = [-1, 1].freeze

    # Each list's angle, by the list.
    def self.call(lists, links) = new(lists, links).angles

    def initialize(lists, links)
      @links = links
      @groups = groups(lists)
      @centre = @groups.max_by { |group| [group.size, -group.first.id] }
    end

    def angles
      return {} if @groups.empty?

      sides = sides(others)
      placed = others.index_with { (sides[it] * offset(it)) + CENTRE }

      by_group = { @centre => CENTRE, **placed }
      by_group.flat_map { |group, angle| group.product([angle]) }.to_h
    end

    private

    # Lists joined, however far apart, by strong links.
    def groups(lists)
      group_of = lists.index_with(&:id)
      @links.select { it.strength >= STRONG }.sort_by(&:id).each do |link|
        from, to = group_of.values_at(link.word_list, link.linked_word_list)
        group_of.transform_values! { it == to ? from : it }
      end

      lists.group_by { group_of[it] }.values
    end

    # The groups off centre, the closest to it first.
    def others
      @others ||=
        (@groups - [@centre]).sort_by do |group|
          [-closeness(group), group.first.id]
        end
    end

    def closeness(group) = between(group, @centre)

    # How strongly two groups' lists are linked.
    def between(group, other)
      joining =
        @links.select do |link|
          ends = [link.word_list, link.linked_word_list]
          ends.intersect?(group) && ends.intersect?(other)
        end

      joining.sum(&:strength)
    end

    def offset(group)
      top = closeness(others.first)
      return FURTHEST if top.zero?

      ((FURTHEST - NEAREST) * (1 - (closeness(group) / top))) + NEAREST
    end

    def sides(groups)
      sides = groups.index_with { stored_side(it) }.compact
      groups.each { sides[it] ||= new_side(it, sides) }
      sides
    end

    def stored_side(group)
      stored = group.filter_map(&:angle)
      mean = stored.sum.fdiv(stored.size) if stored.any?

      SIDES.find { |side| mean && ((mean - CENTRE) * side).positive? }
    end

    def new_side(group, sides)
      friend = sides.keys.max_by { between(group, it) }
      return sides[friend] if friend && between(group, friend).positive?

      SIDES.min_by { |side| sides.values.count(side) }
    end
  end
end
