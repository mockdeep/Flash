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
        render(Components::LevelProgress.new(deck: @deck))
        render_session_bar
      end
    end

    private

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
        span(class: "progress-label__suffix") { " completed" }
      end
    end
  end
end
