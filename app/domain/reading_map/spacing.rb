# frozen_string_literal: true

module ReadingMap
  # Moves the nodes of one ring apart until each has its room, in degrees.
  # The node nearest the centre stays where it is, so a backbone's spoke
  # keeps its line, and the others move outward from it in turn, each side
  # keeping its order. Nothing is stored: the layout's angles say where a
  # list belongs, and this only makes room when they are drawn.
  module Spacing
    # Two angles a hair under their room apart count as clear, since the
    # sums that set them aren't exact.
    SLACK = 0.001

    def self.call(nodes, room:)
      taken = []

      from_centre(nodes).map do |node|
        angle = free_angle(node.angle, taken, room)
        taken << angle
        node.with(angle:)
      end
    end

    def self.from_centre(nodes)
      nodes.sort_by do |node|
        [(node.angle - Layout::CENTRE).abs, node.word_list.id]
      end
    end

    # The nearest angle on the node's own side that is clear of those
    # taken; one at the centre goes to the higher side.
    def self.free_angle(angle, taken, room)
      side = angle < Layout::CENTRE ? -1 : 1
      crowding = taken.select { (it - angle).abs < room - SLACK }
      return angle if crowding.empty?

      furthest = crowding.max_by { it * side }
      free_angle(furthest + (side * room), taken, room)
    end
  end
end
