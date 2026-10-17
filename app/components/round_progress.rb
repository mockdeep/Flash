# frozen_string_literal: true

module Components
  class RoundProgress < Components::Base
    ROUNDS = 3

    def initialize(deck:)
      super()
      @deck = deck
      @completed_rounds = deck.round - 1
    end

    def view_template
      div(class: track_classes) do
        render_segments
        render_tag
      end
    end

    private

    def complete? = @completed_rounds >= ROUNDS

    def track_classes
      complete? ? "round-track round-track--complete" : "round-track"
    end

    def render_segments
      div(class: "round-segments") do
        ROUNDS.times { |i| render_segment(i) }
      end
    end

    def render_segment(index)
      span(class: "round-segment") do
        if index < @completed_rounds
          span(class: "round-fill round-fill--done")
        elsif index == @completed_rounds && current_percent.positive?
          span(class: "round-fill", style: "width: #{current_percent}%")
        end
      end
    end

    def current_percent
      @current_percent ||= compute_current_percent
    end

    def compute_current_percent
      total = @deck.cards_count
      return 0 if total.zero?

      @deck.done_count * 100 / total
    end

    def render_tag
      if complete?
        span(class: "round-tag round-tag--complete") { "Complete ✓" }
      else
        span(class: "round-tag") { "Round #{@deck.round}" }
      end
    end
  end
end
