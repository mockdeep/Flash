# frozen_string_literal: true

module Components
  # The reading map's drawing, behind its buttons and hidden from screen
  # readers: a line at the outer edge of each ring, and the lines between
  # nodes, heavier the stronger they are.
  class MapDrawing < Components::Base
    WIDTH = ::ReadingMap::Chart::WIDTH
    DRAWING = {
      class: "reading-map__drawing",
      viewBox: "0 0 #{WIDTH} #{WIDTH / 2}",
      aria_hidden: "true",
    }.freeze

    attr_accessor :chart

    def initialize(chart:)
      super()
      self.chart = chart
    end

    def view_template
      svg(**DRAWING) do |drawing|
        (1..chart.lines).each { |line| render_line(drawing, line) }
        chart.links.each { |*ends, at| render_link(drawing, ends, at) }
      end
    end

    private

    def render_line(drawing, line)
      radius = chart.radius(line)
      center = WIDTH / 2
      path = "M #{center - radius} #{center} " \
             "A #{radius} #{radius} 0 0 1 #{center + radius} #{center}"

      drawing.path(class: "reading-map__line", d: path)
    end

    def render_link(drawing, ends, strength)
      from, to = ends.map { chart.point(it.ring, it.angle) }
      spots = { x1: from.first, y1: from.last, x2: to.first, y2: to.last }
      style = "--strength: #{strength}"

      drawing.line(class: "reading-map__link", style:, **spots)
    end
  end
end
