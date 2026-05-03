# frozen_string_literal: true

module Components
  class SessionProgress < Components::Base
    def initialize(deck:, completed:, study_goal:)
      super()
      @deck = deck
      @completed = completed
      @study_goal = study_goal
    end

    def view_template
      div(class: "session-progress") do
        render_deck_progress
        render_session_bar
      end
    end

    private

    def render_deck_progress
      div(class: "deck-progress-row") do
        render_stars(@deck.level - 1)
        progress(
          value: @deck.cards.done(@deck.level).count,
          max: @deck.cards.count,
          class: "progress-deck",
        )
      end
    end

    def render_session_bar
      div(class: progress_bar_classes, data: { controller: "dialog" }) do
        render_progress_bar
        render_progress_label
        render(
          Components::StudyGoalDialog.new(deck: @deck, study_goal: @study_goal),
        )
      end
    end

    def render_progress_bar
      progress(
        value: @completed,
        max: @study_goal,
        class: "progress-completed",
      )
    end

    def progress_bar_classes
      classes = "session-progress-bar"
      classes += " session-progress-bar-complete" if @completed >= @study_goal
      classes
    end

    def render_progress_label
      div(class: "progress-label") do
        plain("#{@completed} / ")
        button(
          type: "button",
          class: "milestone-goal-trigger",
          data: { action: "click->dialog#open" },
        ) { @study_goal.to_s }
        plain(" completed")
      end
    end

    def render_stars(completed_levels)
      div(class: "level-stars") do
        3.times do |i|
          if i < completed_levels
            span(class: "star star--filled") { "★" }
          else
            span(class: "star star--empty") { "★" }
          end
        end
        span(class: "level-label") { "Level #{completed_levels + 1}" }
      end
    end
  end
end
