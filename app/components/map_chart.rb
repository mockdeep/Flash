# frozen_string_literal: true

module Components
  # A language's reading map: a list of its rings, inner to outer, each
  # holding its level's chip and its nodes as buttons, which CSS places
  # from the spot given to each. The ring lines and the lines between nodes
  # are a drawing behind them, hidden from screen readers.
  class MapChart < Components::Base
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
      div(class: "reading-map") do
        div(class: "reading-map__canvas") do
          render_drawing
          ol(class: "reading-map__rings") do
            (1..chart.rings).each { |ring| render_ring(ring) }
          end
        end
      end
    end

    private

    def render_drawing
      svg(**DRAWING) do |drawing|
        (1..chart.lines).each { |line| render_line(drawing, line) }
        chart.links.each { |*ends, at| render_link(drawing, ends, at) }
      end
    end

    def render_line(drawing, line)
      radius = chart.radius(line)
      centre = WIDTH / 2
      path = "M #{centre - radius} #{centre} " \
             "A #{radius} #{radius} 0 0 1 #{centre + radius} #{centre}"

      drawing.path(class: "reading-map__line", d: path)
    end

    def render_link(drawing, ends, strength)
      from, to = ends.map { chart.point(it.ring, it.angle) }
      spots = { x1: from.first, y1: from.last, x2: to.first, y2: to.last }
      style = "--strength: #{strength}"

      drawing.line(class: "reading-map__link", style:, **spots)
    end

    # A ring's chip, then its nodes from the lowest angle to the highest.
    def render_ring(ring)
      li(class: "reading-map__ring") do
        chart.chips.select { it.ring == ring }.each { render_chip(it) }
        nodes = chart.nodes.select { it.ring == ring }.sort_by(&:angle)
        nodes.each { render_node(it) }
      end
    end

    def render_chip(chip)
      button(type: "button", class: "reading-map__chip", style: spot(chip)) do
        span(class: "reading-map__name") { chip_label(chip.word_list) }
        render_heat(chip)
      end
    end

    def render_node(node)
      list = node.word_list

      button(type: "button", class: node_class(list), style: spot(node)) do
        render_heat(node)
        span(class: "reading-map__name") { node.word_list.name }
      end
    end

    def render_heat(node)
      span(class: "reading-map__heat") { "#{node.heat.percent}%" }
    end

    # A source is a circle and a list with no text a square; a private one
    # is drawn hollow.
    def node_class(list)
      [
        "reading-map__node",
        ("reading-map__node--list" unless list.source),
        ("reading-map__node--private" unless list.publicly_visible?),
      ].compact.join(" ")
    end

    # Where the node sits, as shares of the canvas's width and height, and
    # how warm it is.
    def spot(node)
      across, down = chart.point(node.ring, node.angle)

      "--across: #{across.round(2)}; --down: #{(down * 2).round(2)}; " \
        "--heat: #{node.heat.percent}"
    end

    # A level list's name without the words every level list's name
    # starts with ("Portuguese (Brazilian) A1" is "A1"), keeping the word
    # before a bare number ("Level 1").
    def chip_label(list)
      label = list.name.split.drop(shared_words.size).join(" ")
      return label if label.match?(/\p{L}/)

      "#{shared_words.last} #{label}".strip
    end

    def shared_words
      @shared_words ||=
        begin
          first, *rest = chart.chips.map { it.word_list.name.split }
          first.zip(*rest).take_while { it.uniq.one? }.map(&:first)
        end
    end
  end
end
