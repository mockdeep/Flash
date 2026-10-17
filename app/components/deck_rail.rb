# frozen_string_literal: true

module Components
  # A `DeckSection` as a heading over a sideways-scrolling rail, with arrows
  # the `rail` controller shows while there is more to scroll to. The block
  # fills the rail with cards.
  class DeckRail < Components::Base
    SECTION_DATA = {
      controller: "rail",
      action: "resize@window->rail#syncArrows",
    }.freeze

    attr_accessor :deck_section

    def initialize(deck_section:)
      super()
      self.deck_section = deck_section
    end

    def view_template(&)
      section(class: "deck-section", data: SECTION_DATA) do
        render_heading
        div(class: "rail-wrap") do
          render_arrow(-1, "‹", "Scroll left")
          render_rail(&)
          render_arrow(1, "›", "Scroll right")
        end
      end
    end

    private

    def render_heading
      h2(class: "decks-section-title") do
        plain(deck_section.name)
        span(class: "section-meta") do
          pluralize(deck_section.decks.size, "deck")
        end
      end
    end

    def render_rail(&)
      div(
        class: "rail",
        data: { rail_target: "rail", action: "scroll->rail#syncArrows" },
        &
      )
    end

    def render_arrow(direction, glyph, label)
      side = direction.negative? ? "left" : "right"
      button(
        type: "button",
        class: "rail-arrow rail-arrow--#{side}",
        aria: { label: },
        data: arrow_data(direction, side),
        hidden: true,
      ) { glyph }
    end

    def arrow_data(direction, side)
      {
        action: "rail#scroll",
        rail_dir_param: direction,
        rail_target: "#{side}Arrow",
      }
    end
  end
end
