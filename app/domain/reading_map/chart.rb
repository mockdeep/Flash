# frozen_string_literal: true

module ReadingMap
  # What a learner's reading map shows for one language: its rings, a chip
  # per level list, a node per other list they can see, and the lines
  # between those. Rings count outward from 1: one per level, then one more
  # past the top level for lists beyond it; a language with no level lists
  # has a single ring. A node sits in the middle of its ring's space at its
  # list's stored angle, moved along the ring where it would crowd another.
  class Chart
    # Where chips sit: the end of the half ring.
    CHIP_ANGLE = 180.0
    # The drawing's size: twice as wide as high, the center at the middle
    # of its flat lower edge.
    WIDTH = 100.0
    # A node's room along its ring, in the drawing's units. A ring further
    # out is longer, so the same room is a smaller angle there; MOST_ROOM
    # degrees is the most a node gets, so a few still fit on a short ring.
    ROOM = 9.0
    MOST_ROOM = 60.0

    attr_reader :language

    def initialize(user:, language:)
      @user = user
      @language = language
    end

    def name = WordList::LANGUAGES[language]

    # Lines are drawn at the outer edge of each level's ring, and of the
    # one ring of a language with no levels.
    def lines = [levels.size, 1].max

    def rings = levels.any? ? levels.size + 1 : 1

    def chips
      @chips ||=
        level_lists.select { visible.ids.include?(it.id) }.map do |list|
          node(list, levels.index(list.level) + 1, CHIP_ANGLE)
        end
    end

    def nodes
      @nodes ||= spaced(placed.map { node(it, ring(it), it.angle) })
    end

    # Where the map opens and Recenter returns to: the learner's next
    # node, or with nothing started the innermost node up the center, if
    # any node is.
    def start
      spoke = nodes.select { it.angle == Layout::CENTER }

      next_node || spoke.min_by { [it.ring, it.word_list.id] }
    end

    # Among the started chips and nodes short of today's goal, the one on
    # the innermost ring, then the most recently studied; with every goal
    # met, the most recently studied.
    def next_node
      started = [*chips, *nodes].select(&:started?)
      unmet = started.select(&:unmet?)
      innermost = unmet.select { it.ring == unmet.map(&:ring).min }

      (innermost.presence || started).max_by(&:last_studied)
    end

    # Each line between two nodes on the map, with its strength.
    def links
      on_map = nodes.index_by(&:word_list)
      joining = WordListLink.where(word_list: on_map.keys)
        .where(linked_word_list: on_map.keys)

      joining.map do |link|
        ends = on_map.values_at(link.word_list, link.linked_word_list)
        [*ends, link.strength]
      end
    end

    # A spot's place in the drawing, across and down from its top left.
    def point(ring, angle)
      radius = middle(ring)
      radians = angle * Math::PI / 180

      [
        (WIDTH / 2) - (radius * Math.cos(radians)),
        (WIDTH / 2) - (radius * Math.sin(radians)),
      ]
    end

    # How far out a line is drawn, as its ring's outer edge.
    def radius(line) = line * WIDTH / 2 / rings

    private

    # How far out the middle of a ring's space is.
    def middle(ring) = radius(ring - 0.5)

    def room(ring) = [ROOM / middle(ring) * 180 / Math::PI, MOST_ROOM].min

    def node(list, ring, angle)
      decks = decks_by_list.fetch(list.id, [])
      unmet = decks.any? { unmet_ids.include?(it.id) }
      heat = heats[list.id]

      Node.new(word_list: list, ring:, angle:, heat:, decks:, unmet:)
    end

    # The learner's decks over the lists on the map, by list.
    def decks_by_list
      @decks_by_list ||=
        @user.decks.where(word_list: visible).group_by(&:word_list_id)
    end

    # Unmet as Next Deck counts it: a deck waiting for tomorrow isn't.
    def unmet_ids
      @unmet_ids ||= @user.decks.goal_unmet_today.where(word_list: visible)
        .reject(&:waiting_for_tomorrow?).map(&:id)
    end

    def heats
      @heats ||= Heat.for(@user, visible.select(:id))
    end

    def levels = @levels ||= level_lists.map(&:level).uniq

    def level_lists
      @level_lists ||= WordList.where(language:, curriculum: true)
        .where.not(level: nil).order(:level, :id).to_a
    end

    # The lists with a place: every one but the level lists, once the
    # layout has given it an angle.
    def placed
      visible.where(curriculum: false).where.not(angle: nil).order(:id)
    end

    # A list with no level in a language that has them hasn't been placed
    # on a ring yet, so it waits past the last.
    def ring(list)
      return 1 if levels.empty?

      levels.index(list.level)&.succ || rings
    end

    # Public lists, the learner's own or shared sources, and any list they
    # have a deck for. A source's list shows only once it has a snippet to
    # read.
    def visible
      lists = WordList.where(visibility: "public")
        .or(WordList.where(id: readable_sources.select(:word_list_id)))
        .or(WordList.where(id: @user.decks.select(:word_list_id)))

      lists.where(language:).where.not(id: unread.select(:word_list_id))
    end

    def readable_sources
      shared = @user.source_readers.select(:source_id)

      Source.where(word_list: @user.word_lists).or(Source.where(id: shared))
    end

    def unread
      Source.where.not(id: Snippet.studyable.select(:source_id))
    end

    def spaced(nodes)
      nodes.group_by(&:ring).flat_map do |ring, on_ring|
        Spacing.call(on_ring, room: room(ring))
      end
    end
  end
end
