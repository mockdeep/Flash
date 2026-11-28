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
    def lines = [ring_set.levels.size, 1].max

    def rings = ring_set.count

    def chips
      @chips ||=
        ring_set.level_lists.select { visible.ids.include?(it.id) }
          .map { node(it, CHIP_ANGLE) }
    end

    def nodes
      @nodes ||= spaced(placed.map { node(it, it.angle) })
    end

    # Where the map opens and Recenter returns to: the learner's next
    # node, or with nothing started the innermost node up the center, if
    # any node is.
    def start
      spoke = nodes.select { it.angle == Layout::CENTER }

      next_node || spoke.min_by { [it.ring, it.word_list.id] }
    end

    # The chip or node of the list that comes next (`Started#next_list`).
    def next_node
      list = started.next_list

      [*chips, *nodes].find { it.word_list == list }
    end

    delegate :links, :leads, to: :joining

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

    def node(list, angle)
      Node.new(
        word_list: list,
        ring: ring_set.of(list),
        angle:,
        heat: heats[list.id],
        deck: started.deck(list.id),
        unmet: started.unmet?(list.id),
      )
    end

    def started
      @started ||=
        begin
          decks = @user.decks.where(word_list: WordList.where(language:))
          Started.new(decks:, language:)
        end
    end

    def ring_set = @ring_set ||= Rings.new(language)

    def joining = @joining ||= Lines.new(user: @user, nodes:)

    def heats
      @heats ||= Heat.for(@user, visible.select(:id))
    end

    # The lists with a place: every one but the level lists, once the
    # layout has given it an angle.
    def placed
      visible.where(curriculum: false).where.not(angle: nil).order(:id)
    end

    def visible = WordList.visible_to(@user).where(language:)

    def spaced(nodes)
      nodes.group_by(&:ring).flat_map do |ring, on_ring|
        Spacing.call(on_ring, room: room(ring))
      end
    end
  end
end
