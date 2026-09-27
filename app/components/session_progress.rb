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
      div(class: "session-progress", data: { controller: "dialog" }) do
        render(Components::LevelProgress.new(deck: @deck))
        @deck.no_goal? ? render_count : render_session_bar
        render(Components::TargetPrompt.new(deck: @deck))
      end
    end

    private

    def render_session_bar
      div(class: progress_bar_classes) do
        render_progress_bar
        render_progress_label
        render(goal_dialog)
      end
    end

    def render_count
      div(class: "progress-label") do
        plain("#{@completed} completed")
        span(class: "progress-label__suffix") { " today" }
        plain(" · ")
        goal_trigger("set goal")
      end
      render(goal_dialog)
    end

    def goal_dialog
      Components::StudyGoalDialog.new(deck: @deck, study_goal: @study_goal)
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
        goal_trigger(@study_goal.to_s)
        span(class: "progress-label__suffix") { " completed" }
      end
    end

    def goal_trigger(text)
      button(
        type: "button",
        class: "milestone-goal-trigger",
        data: { action: "click->dialog#open" },
      ) { text }
    end
  end
end
