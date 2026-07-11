# frozen_string_literal: true

module Components
  class LevelProgress < Components::Base
    LEVELS = 3

    def initialize(deck:)
      super()
      @deck = deck
      @completed_levels = deck.level - 1
    end

    def view_template
      div(class: track_classes) do
        render_segments
        render_tag
      end
    end

    private

    def complete? = @completed_levels >= LEVELS

    def track_classes
      complete? ? "level-track level-track--complete" : "level-track"
    end

    def render_segments
      div(class: "level-segments") do
        LEVELS.times { |i| render_segment(i) }
      end
    end

    def render_segment(index)
      span(class: "level-segment") do
        if index < @completed_levels
          span(class: "level-fill level-fill--done")
        elsif index == @completed_levels && current_percent.positive?
          span(class: "level-fill", style: "width: #{current_percent}%")
        end
      end
    end

    def current_percent
      @current_percent ||= compute_current_percent
    end

    def compute_current_percent
      total = @deck.cards.count
      return 0 if total.zero?

      @deck.cards.done(@deck.level).count * 100 / total
    end

    def render_tag
      if complete?
        span(class: "level-tag level-tag--complete") { "Complete ✓" }
      else
        span(class: "level-tag") { "Level #{@deck.level}" }
      end
    end
  end
end
