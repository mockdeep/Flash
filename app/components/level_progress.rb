# frozen_string_literal: true

module Components
  # A deck's words as one bar split by how far each has got: finished,
  # then each level from the top down, then those not seen yet.
  class LevelProgress < Components::Base
    def initialize(deck:)
      super()
      @deck = deck
    end

    def view_template
      div(class: "round-track") do
        div(class: "level-bar", title:) do
          parts.each do |name, count|
            span(class: "level-bar__#{name}", style: "flex-grow: #{count}")
          end
        end
        span(class: tag_classes) { tag_text }
      end
    end

    private

    def parts
      levels = Deck::LEVELS.downto(1).map { ["level#{it}", @deck.level_count(it)] }
      [["finished", @deck.done_count], *levels, ["new", @deck.new_count]]
        .select { |_, count| count.positive? }
    end

    def title = parts.map { |name, count| "#{name}: #{count}" }.join(", ")

    # From the counts the rail loaded, so no further query.
    def finished?
      @deck.cards_count.positive? && @deck.done_count == @deck.cards_count
    end

    def tag_classes = ["round-tag", ("round-tag--complete" if finished?)]

    def tag_text
      return "Complete ✓" if finished?

      total = @deck.cards_count
      percent = total.zero? ? 0 : @deck.done_count * 100 / total
      "#{percent}% finished"
    end
  end
end
