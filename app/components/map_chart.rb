# frozen_string_literal: true

module Components
  # A language's reading map: a list of its rings, inner to outer, each
  # holding its level's chip and its nodes as buttons, which CSS places
  # from the spot given to each. The ring lines and the lines between nodes
  # are a drawing behind them, hidden from screen readers.
  class MapChart < Components::Base
    attr_accessor :chart

    def initialize(chart:)
      super()
      self.chart = chart
    end

    def view_template
      div(data: { controller: "reading-map" }) do
        render(Components::MapControls.new)
        div(class: "reading-map", data: { reading_map_target: "box" }) do
          render_canvas
        end
      end
    end

    private

    def render_canvas
      data = { reading_map_target: "canvas" }

      div(class: "reading-map__canvas", data:) do
        render(Components::MapDrawing.new(chart:))
        ol(class: "reading-map__rings") do
          (1..chart.rings).each { |ring| render_ring(ring) }
        end
      end
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
      render_spot(chip, ["reading-map__chip"]) do
        span(class: "reading-map__name") { chip_label(chip.word_list) }
        render_heat(chip)
      end
    end

    def render_node(node)
      render_spot(node, node_classes(node.word_list)) do
        render_heat(node)
        span(class: "reading-map__name") { node.word_list.name }
      end
    end

    # A chip or node as a button that opens its popover, marked once the
    # learner has a deck for it, and as the one the map opens on.
    def render_spot(node, classes, &)
      classes += ["reading-map__started"] if node.started?
      data = { reading_map_target: ("start" if node == chart.start) }
      id = "map-list-#{node.word_list.id}"
      look = { class: classes, style: spot(node) }

      button(type: "button", popovertarget: id, data:, **look, &)
      render(Components::MapPopover.new(id:, node:, leads: chart.leads(node)))
    end

    def render_heat(node)
      span(class: "reading-map__heat") { "#{node.heat.percent}%" }
      span(class: "reading-map__tick") { "✓" } if node.met?
    end

    # A source is a circle and a list with no text a square; a private one
    # is drawn hollow.
    def node_classes(list)
      [
        "reading-map__node",
        ("reading-map__node--list" unless list.source),
        ("reading-map__node--private" unless list.publicly_visible?),
      ].compact
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
